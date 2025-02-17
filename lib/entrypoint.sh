#!/bin/sh

# With problem matchers in a container, the matcher config MUST be available
# outside the container on the VM so we will just copy it into the workspace.
# See: https://github.com/actions/toolkit/issues/205#issuecomment-557647948
matcher_path=`pwd`/git-grep-problem-matcher.json
cp /git-grep-problem-matcher.json "$matcher_path"



case_sensitive="${1}"
severity=${2}

if [ "${secerity}" != "WARNING" ] && [ "${severity}" != "ERROR" ]; then
	echo "ERROR: severity must be one of WARNING or ERROR"
	if [ "${INVERT_ERROR}" = "" ]; then
		exit 1
	else
		exit 0
	fi
fi
if [ ${case_sensitive} = false ]; then
	case_sensitive="--ignore-case"
else
	unset case_sensitive
fi

echo "::add-matcher::git-grep-problem-matcher.json"

tag=${INPUT_TERMS:=FIXME}
result=$(git grep --no-color ${case_sensitive} --line-number --extended-regexp -e "(${tag})+(:)" :^.github |  sed -e "s/^/${severity} /" )

echo "${result}"

if [ -n "${result}" ] && [ "${severity}" = "ERROR" ]; then
	if [ "${INVERT_ERROR}" = "" ]; then
		exit 1
elif [ "${INVERT_ERROR}" = "true" ]; then
	exit 1
fi
