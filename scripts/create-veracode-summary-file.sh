#!/usr/bin/env bash
set -Eeu

SCRIPT_NAME=creat-veracode-summary-file.sh
ROOT_DIR=$(dirname $(readlink -f $0))/..
INPUT_FILE=""
OUTPUT_FILE=""

function print_help
{
    cat <<EOF
Usage: $SCRIPT_NAME <options> [VERACODE-RESULT-FILE.json] [VERACODE-SUMMARY-FILE.json]

Convert a veracode scan json file with a listing of all found issues
to a json file with a summary of how many findings there are for
each severity and gob (Grace of service)

Options are:
  -h          Print this help menu
EOF
}

function check_arguments
{
    while getopts "h" opt; do
        case $opt in
            h)
                print_help
                exit 1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
    done

    # Remove options from command line
    shift $((OPTIND-1))

    if [ $# -ne 2 ]; then
        echo "Missing file arguments"
        exit 1
    fi
    INPUT_FILE=$1; shift
    OUTPUT_FILE=$1; shift
}

main()
{
    check_arguments "$@"
    # Count how many of each severity and gob. If there is no .findings, which is when there are
    # no errors, we report 0 on all severity and gob.
    jq '{
        severity_summary: {
            severity_1: (.findings // [] | map(select(.severity == 1)) | length),
            severity_2: (.findings // [] | map(select(.severity == 2)) | length),
            severity_3: (.findings // [] | map(select(.severity == 3)) | length),
            severity_4: (.findings // [] | map(select(.severity == 4)) | length),
            severity_5: (.findings // [] | map(select(.severity == 5)) | length)
        },
        gob_summary: {
            gob_a: (.findings // [] | map(select(.gob == "A")) | length),
            gob_b: (.findings // [] | map(select(.gob == "B")) | length),
            gob_c: (.findings // [] | map(select(.gob == "C")) | length),
            gob_d: (.findings // [] | map(select(.gob == "D")) | length)
        }
    } + del(.findings)' ${INPUT_FILE} > ${OUTPUT_FILE}

}

main "$@"
