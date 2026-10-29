#!/bin/bash
# Source-only Ubuntu precompiled NVIDIA selection; no package or APT changes.
# select_ubuntu_precompiled_driver KERNEL... clears its four public outputs on
# entry and publishes a complete selection only on success. MODULE_ARGS includes
# exact per-kernel packages and one compatible tracking meta per kernel flavour.
# Requires Bash 4.3+, apt-cache, and sort; uses the caller's existing APT indexes.
# ubuntu_nvidia_archive_conflicts PACKAGE[:ARCH]=VERSION... inspects downloaded
# archives without changing packages. It prints unique conflicting driver owners;
# the caller supplies is_ubuntu_nvidia_driver_package and its source metadata map.
# Archive inspection additionally uses apt-config, dpkg, dpkg-deb, dpkg-query, tar.

# Retain only downloadable Ubuntu records and fields needed by the selector.
_ubuntu_precompiled_metadata() {
    local text="$1" line field='' key package version
    local -n result="$2"
    local -A record=()
    result=()
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            package=${record[Package]:-}
            version=${record[Version]:-}
            if [[ -n "$package" && -n "$version" && ${record[Origin]:-} == Ubuntu && -n ${record[Filename]:-} ]]; then
                for key in "${!record[@]}"; do
                    result["$package|$version|$key"]=${record[$key]}
                done
            fi
            record=()
            field=''
        elif [[ "$line" =~ ^([A-Za-z-]+):[[:space:]]?(.*)$ ]]; then
            field=${BASH_REMATCH[1]}
            case "$field" in
                Package|Version|Origin|Filename|Built-Using|Provides|Depends)
                    record[$field]=${BASH_REMATCH[2]} ;;
                *) field='' ;;
            esac
        elif [[ -n "$field" && "$line" == [[:space:]]* ]]; then
            record[$field]+=" $line"
        fi
    done <<< "$text"$'\n'
}

_ubuntu_precompiled_upstream() {
    local version=${1#*:}
    printf '%s' "${version%-*}"
}

select_ubuntu_precompiled_driver() {
    UBUNTU_PRECOMPILED_DRIVER_PACKAGE=''
    UBUNTU_PRECOMPILED_DRIVER_VERSION=''
    UBUNTU_PRECOMPILED_MODULE_ARGS=()
    UBUNTU_PRECOMPILED_KERNELS=()

    local kernel kernel_flavour names package driver flavour dkms policy line
    local policy_package candidate driver_version upstream metadata_text key
    local module built_version pattern provided_version meta meta_version
    local dependency dependency_name dependency_version found valid complete
    local reason='no available Ubuntu open driver has matching precompiled modules'
    local -a kernels=() kernel_flavours=() drivers=() packages=() specs=()
    local -a module_args=() metas=() versions=() dependencies=()
    local -A seen_kernels=() seen_flavours=() candidates=() metadata=()
    local -A module_versions=() meta_metadata=()

    if (( $# == 0 )); then
        printf '%s\n' 'Ubuntu precompiled NVIDIA selection requires at least one kernel release.' >&2
        return 1
    fi
    for kernel in "$@"; do
        if [[ ! "$kernel" =~ ^[[:digit:]][[:alnum:].+~]*-[[:digit:]]+-([[:alnum:]][[:alnum:]+.-]*)$ ]]; then
            printf 'Unsupported Ubuntu kernel release: %s\n' "$kernel" >&2
            return 1
        fi
        kernel_flavour=${BASH_REMATCH[1]}
        if [[ -z ${seen_kernels[$kernel]:-} ]]; then
            kernels+=("$kernel")
            seen_kernels[$kernel]=1
        fi
        if [[ -z ${seen_flavours[$kernel_flavour]:-} ]]; then
            kernel_flavours+=("$kernel_flavour")
            seen_flavours[$kernel_flavour]=1
        fi
    done
    if ! names=$(LC_ALL=C apt-cache pkgnames nvidia-driver- 2>/dev/null); then
        printf '%s\n' 'Cannot read NVIDIA driver names from the APT cache.' >&2
        return 1
    fi
    while IFS= read -r package; do
        if [[ "$package" =~ ^nvidia-driver-[[:digit:]]+(-server)?-open$ ]]; then
            drivers+=("$package")
        fi
    done <<< "$names"
    if (( ${#drivers[@]} == 0 )); then
        printf '%s\n' 'No branch-specific open NVIDIA drivers are available in the APT cache.' >&2
        return 1
    fi
    # Version sorting orders branches descending, server-open before open.
    if ! names=$(printf '%s\n' "${drivers[@]}" | LC_ALL=C sort -Vru); then
        printf '%s\n' 'Cannot order available NVIDIA driver branches.' >&2
        return 1
    fi
    mapfile -t drivers <<< "$names"

    for driver in "${drivers[@]}"; do
        flavour=${driver#nvidia-driver-}
        dkms="nvidia-dkms-$flavour"
        packages=("$driver")
        for kernel in "${kernels[@]}"; do
            packages+=("linux-modules-nvidia-$flavour-$kernel")
        done
        if ! policy=$(LC_ALL=C apt-cache policy "${packages[@]}" 2>/dev/null); then
            reason="cannot read APT candidates for $driver"
            continue
        fi
        candidates=()
        policy_package=''
        while IFS= read -r line; do
            if [[ "$line" != [[:space:]]* && "$line" == *: ]]; then
                policy_package=${line%:}
                policy_package=${policy_package%%:*}
            elif [[ -n "$policy_package" && "$line" =~ ^[[:space:]]*Candidate:[[:space:]]+([^[:space:]]+) ]]; then
                candidate=${BASH_REMATCH[1]}
                if [[ "$candidate" != '(none)' ]]; then
                    candidates[$policy_package]=$candidate
                fi
            fi
        done <<< "$policy"
        specs=()
        complete=1
        for package in "${packages[@]}"; do
            if [[ -z ${candidates[$package]:-} ]]; then
                reason="no APT candidate for $package"
                complete=0
                break
            fi
            specs+=("$package=${candidates[$package]}")
        done
        (( complete )) || continue
        if ! metadata_text=$(LC_ALL=C apt-cache show --no-all-versions "${specs[@]}" 2>/dev/null); then
            reason="cannot read package metadata for $driver"
            continue
        fi
        _ubuntu_precompiled_metadata "$metadata_text" metadata
        driver_version=${candidates[$driver]}
        if [[ ${metadata["$driver|$driver_version|Origin"]:-} != Ubuntu ]]; then
            reason="$driver candidate is not a downloadable Ubuntu package"
            continue
        fi
        upstream=$(_ubuntu_precompiled_upstream "$driver_version")
        pattern="(^|,[[:space:]]*)${dkms}[[:space:]]+\\(=[[:space:]]+([^)]*)\\)"
        module_args=()
        module_versions=()
        for kernel in "${kernels[@]}"; do
            module="linux-modules-nvidia-$flavour-$kernel"
            candidate=${candidates[$module]}
            if [[ ! ${metadata["$module|$candidate|Built-Using"]:-} =~ $pattern ]]; then
                reason="$module has no Ubuntu Built-Using record for $dkms"
                complete=0
                break
            fi
            built_version=${BASH_REMATCH[2]}
            if [[ $(_ubuntu_precompiled_upstream "$built_version") != "$upstream" ]]; then
                reason="$module was built for a different NVIDIA upstream version"
                complete=0
                break
            fi
            module_args+=("$module=$candidate")
            module_versions[$module]=$candidate
        done
        (( complete )) || continue

        metas=()
        for kernel_flavour in "${kernel_flavours[@]}"; do
            metas+=("linux-modules-nvidia-$flavour-$kernel_flavour")
        done
        # All available versions matter: the newest meta may target a kernel
        # not supplied by the caller. Never select such a meta implicitly.
        if ! metadata_text=$(LC_ALL=C apt-cache show --all-versions "${metas[@]}" 2>/dev/null); then
            reason="cannot read tracking module metadata for $driver"
            continue
        fi
        _ubuntu_precompiled_metadata "$metadata_text" meta_metadata
        for meta in "${metas[@]}"; do
            versions=()
            for key in "${!meta_metadata[@]}"; do
                if [[ "$key" == "$meta|"*'|Version' ]]; then
                    versions+=("${meta_metadata[$key]}")
                fi
            done
            if (( ${#versions[@]} )); then
                names=$(printf '%s\n' "${versions[@]}" | LC_ALL=C sort -Vru)
                mapfile -t versions <<< "$names"
            fi
            found=0
            for meta_version in "${versions[@]}"; do
                if [[ ! ${meta_metadata["$meta|$meta_version|Provides"]:-} =~ $pattern ]]; then
                    continue
                fi
                provided_version=${BASH_REMATCH[2]}
                [[ $(_ubuntu_precompiled_upstream "$provided_version") == "$upstream" ]] || continue
                IFS=',' read -r -a dependencies <<< "${meta_metadata["$meta|$meta_version|Depends"]:-}"
                valid=1
                found=0
                for dependency in "${dependencies[@]}"; do
                    if [[ "$dependency" == *linux-modules-nvidia-* ]]; then
                        if [[ ! "$dependency" =~ ^[[:space:]]*(linux-modules-nvidia-[^[:space:]\(\)\|]+)([[:space:]]+\(=[[:space:]]+([^\)]*)\))?[[:space:]]*$ ]]; then
                            valid=0
                            break
                        fi
                        dependency_name=${BASH_REMATCH[1]}
                        dependency_version=${BASH_REMATCH[3]:-}
                        if [[ -z ${module_versions[$dependency_name]:-} ||
                              ( -n "$dependency_version" && "$dependency_version" != "${module_versions[$dependency_name]}" ) ]]; then
                            valid=0
                            break
                        fi
                        found=1
                    elif [[ "$dependency" =~ (^|[[:space:]\|])linux-(image|headers|modules|objects|signatures)- ]]; then
                        # A tracking meta must not introduce another kernel.
                        valid=0
                        break
                    fi
                done
                if (( valid && found )); then
                    module_args+=("$meta=$meta_version")
                    break
                fi
                found=0
            done
            if (( ! found )); then
                reason="no available $meta version tracks only the supplied kernels and NVIDIA $upstream"
                complete=0
                break
            fi
        done
        (( complete )) || continue
        UBUNTU_PRECOMPILED_DRIVER_PACKAGE=$driver
        UBUNTU_PRECOMPILED_DRIVER_VERSION=$driver_version
        UBUNTU_PRECOMPILED_MODULE_ARGS=("${module_args[@]}")
        UBUNTU_PRECOMPILED_KERNELS=("${kernels[@]}")
        return 0
    done
    printf 'No consistent Ubuntu precompiled NVIDIA package set: %s.\n' "$reason" >&2
    return 1
}

ubuntu_nvidia_archive_conflicts() {
    (( $# )) || return 0
    local config archive_dir='' native_arch specification package version architecture
    local archive metadata archive_package archive_version archive_arch replaces listing
    local path pattern matches status line owners owner owner_name relation replacement
    local operator replacement_version owner_version owner_status inventory key
    local -a requested=("$@") paths=() patterns=() owner_list=() relations=()
    local -A wanted=() archives=() replacements=() conflicts=() versions=() statuses=()
    local -A queried_paths=()

    if ! config=$(apt-config shell archive_dir Dir::Cache::archives/d) ||
       ! native_arch=$(dpkg --print-architecture); then
        printf '%s\n' 'Cannot locate the configured APT archive cache or native architecture.' >&2
        return 1
    fi
    eval "$config"
    if [[ -z "$archive_dir" || ! -d "$archive_dir" ]]; then
        printf 'APT archive directory is unavailable: %s\n' "$archive_dir" >&2
        return 1
    fi
    for specification in "${requested[@]}"; do
        if [[ ! "$specification" =~ ^([a-z0-9][a-z0-9+.-]*)(:([a-z0-9][a-z0-9-]*))?=(.+)$ ]]; then
            printf 'Expected an exact package=version archive request: %s\n' "$specification" >&2
            return 1
        fi
        package=${BASH_REMATCH[1]}
        architecture=${BASH_REMATCH[3]:-$native_arch}
        version=${BASH_REMATCH[4]}
        wanted["$package|$version|$architecture"]=$specification
        wanted["$package|$version|all"]=$specification
    done
    # Filenames encode epochs and architectures inconsistently; trust metadata.
    for archive in "$archive_dir"/*.deb; do
        [[ -e "$archive" ]] || continue
        if ! metadata=$(dpkg-deb --show --showformat='${Package}\t${Version}\t${Architecture}\t${Replaces}\n' "$archive"); then
            printf 'Cannot inspect cached package metadata: %s\n' "$archive" >&2
            return 1
        fi
        IFS=$'\t' read -r archive_package archive_version archive_arch replaces <<< "$metadata"
        key="$archive_package|$archive_version|$archive_arch"
        [[ -n ${wanted[$key]:-} ]] || continue
        specification=${wanted[$key]}
        archives[$specification]=$archive
        replacements[$specification]=$replaces
    done
    for specification in "${requested[@]}"; do
        if [[ -z ${archives[$specification]:-} ]]; then
            printf 'Exact downloaded archive is missing: %s\n' "$specification" >&2
            return 1
        fi
    done
    if ! inventory=$(dpkg-query -W -f='${binary:Package}\t${Version}\t${db:Status-Status}\n'); then
        printf '%s\n' 'Cannot inspect installed package versions for archive ownership.' >&2
        return 1
    fi
    while IFS=$'\t' read -r owner owner_version owner_status; do
        [[ -n "$owner" ]] || continue
        versions[$owner]=$owner_version
        statuses[$owner]=$owner_status
    done <<< "$inventory"
    for specification in "${requested[@]}"; do
        package=${specification%%=*}
        package=${package%%:*}
        archive=${archives[$specification]}
        if ! listing=$(set -o pipefail; dpkg-deb --fsys-tarfile "$archive" | tar --list --file=- --quoting-style=literal); then
            printf 'Cannot inspect cached package files: %s\n' "$archive" >&2
            return 1
        fi
        paths=()
        while IFS= read -r path; do
            [[ -n "$path" && "$path" != */ ]] || continue
            path=${path#./}
            path="/${path#/}"
            paths+=("$path")
        done <<< "$listing"
        # Bound argument sizes while avoiding a dpkg-query process per file.
        for (( status=0; status<${#paths[@]}; status+=128 )); do
            patterns=()
            queried_paths=()
            for path in "${paths[@]:status:128}"; do
                queried_paths[$path]=1
                pattern=${path//\\/\\\\}
                pattern=${pattern//\*/\\*}
                pattern=${pattern//\?/\\?}
                pattern=${pattern//\[/\\[}
                patterns+=("$pattern")
            done
            # Exit 1 means at least one path has no owner; exit 2 is a fatal error.
            if matches=$(LC_ALL=C dpkg-query -S "${patterns[@]}" 2>&1); then
                :
            elif (( $? != 1 )); then
                printf 'Cannot query installed file owners:\n%s\n' "$matches" >&2
                return 1
            fi
            while IFS= read -r line; do
                [[ -n "$line" ]] || continue
                [[ "$line" == 'dpkg-query: no path found matching pattern '* ]] && continue
                path=${line#*: }
                owners=${line%%: /*}
                if [[ -z ${queried_paths[$path]:-} || "$owners" == "$line" ]]; then
                    printf 'Cannot interpret installed file ownership: %s\n' "$line" >&2
                    return 1
                fi
                IFS=',' read -r -a owner_list <<< "$owners"
                for owner in "${owner_list[@]}"; do
                    owner=${owner# }
                    owner_name=${owner%%:*}
                    [[ "$owner_name" == "$package" ]] && continue
                    case "${statuses[$owner]:-}" in
                        config-files|not-installed) continue ;;
                        '') printf 'Cannot find installed status for file owner %s.\n' "$owner" >&2; return 1 ;;
                    esac
                    # A satisfied Replaces permits the overwrite; it is not a collision.
                    replacement=''
                    IFS=',' read -r -a relations <<< "${replacements[$specification]}"
                    for relation in "${relations[@]}"; do
                        if [[ "$relation" =~ ^[[:space:]]*([a-z0-9][a-z0-9+.-]*)(:([a-z0-9-]+))?([[:space:]]+\(([^\ ]+)[[:space:]]+([^\)]+)\))?[[:space:]]*$ ]]; then
                            [[ ${BASH_REMATCH[1]} == "$owner_name" ]] || continue
                            architecture=${BASH_REMATCH[3]}
                            operator=${BASH_REMATCH[5]}
                            replacement_version=${BASH_REMATCH[6]}
                            if [[ -n "$architecture" && "$architecture" != any &&
                                  "$architecture" != "${owner#*:}" &&
                                  ! ( "$owner" != *:* && "$architecture" == "$native_arch" ) ]]; then
                                continue
                            fi
                            if [[ -z "$operator" ]] ||
                               dpkg --compare-versions "${versions[$owner]}" "$operator" "$replacement_version"; then
                                replacement=1
                                break
                            fi
                        fi
                    done
                    [[ -n "$replacement" ]] && continue
                    if ! is_ubuntu_nvidia_driver_package "$owner"; then
                        printf 'Refusing archive collision: %s would overwrite %s owned by unrelated package %s.\n' \
                            "$specification" "$path" "$owner" >&2
                        return 1
                    fi
                    conflicts[$owner]=1
                done
            done <<< "$matches"
        done
    done
    if (( ${#conflicts[@]} )); then
        printf '%s\n' "${!conflicts[@]}" | LC_ALL=C sort -u
    fi
}
