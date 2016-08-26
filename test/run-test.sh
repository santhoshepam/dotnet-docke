#!/usr/bin/env bash
set -e 	# Exit immediately upon failure
set -o pipefail  # Carry failures over pipes

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
docker_repo="microsoft/dotnet-nightly"

if [ -z "${DEBUGTEST}" ]; then
    optional_docker_run_args="--rm"
fi

pushd "${repo_root}" > /dev/null

for cli_channel in $( find . -mindepth 1 -maxdepth 1 -type d ! -name '.*' ! -name 'test' ! -name 'update-dependencies' -print | sed -e 's/\.\///' ); do
    tag_base="${docker_repo}:${cli_channel}"

    app_name="app$(date +%s)"
    app_dir="${repo_root}/.test-assets/${app_name}"
    mkdir -p "${app_dir}"

    echo "----- Testing ${tag_base}-sdk -----"
    docker run -t "${optional_docker_run_args}" -v "${app_dir}:/${app_name}" -v "${repo_root}/test:/test" --name "sdk-test-${app_name}" --entrypoint /test/create-run-publish-app.sh "${tag_base}-sdk" "${app_name}"

    echo "----- Testing ${tag_base}-core -----"
    docker run -t "${optional_docker_run_args}" -v "${app_dir}:/${app_name}" --name "core-test-${app_name}" --entrypoint dotnet "${tag_base}-core" "/${app_name}/publish/${app_name}.dll"

    echo "----- Testing ${tag_base}-onbuild -----"
    pushd "${app_dir}" > /dev/null
    echo "FROM ${tag_base}-onbuild" > Dockerfile
    docker build -t "${app_name}-onbuild" .
    popd > /dev/null
    docker run -t "${optional_docker_run_args}" --name "onbuild-test-${app_name}" "${app_name}-onbuild"

    if [ -z "${DEBUGTEST}" ]; then
        docker rmi "${app_name}-onbuild"
    fi
done

popd > /dev/null
