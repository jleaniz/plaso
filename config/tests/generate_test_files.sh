#!/bin/bash
#
# Script to generate test files.

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

TEST_DIRECTORY="/tmp/test";

if ! test -x "setup.py";
then
	echo "Unable to find: ./setup.py";

	exit ${EXIT_FAILURE};
fi

rm -rf build/ dist/;

./setup.py -q sdist;

if test $? -ne ${EXIT_SUCCESS};
then
	echo "Unable to run: ./setup.py sdist";

	exit ${EXIT_FAILURE};
fi

SDIST_PACKAGE=`ls -1 dist/plaso-*.tar.gz | head -n1 | sed 's?^dist/??'`;

if ! test "dist/${SDIST_PACKAGE}";
then
	echo "Missing sdist package: dist/${SDIST_PACKAGE}";

	exit ${EXIT_FAILURE};
fi

OLD_PWD=${PWD};

mkdir ${TEST_DIRECTORY};

if ! test -d "${TEST_DIRECTORY}";
then
	echo "Missing test directory: ${TEST_DIRECTORY}";

	exit ${EXIT_FAILURE};
fi

cp dist/${SDIST_PACKAGE} ${TEST_DIRECTORY};

cd ${TEST_DIRECTORY};

if ! test -f "${SDIST_PACKAGE}";
then
	echo "Missing sdist package: ${SDIST_PACKAGE}";

	exit ${EXIT_FAILURE};
fi

tar xfv ${SDIST_PACKAGE};

SOURCE_DIRECTORY=${SDIST_PACKAGE/.tar.gz/};

if ! test -d "./${SOURCE_DIRECTORY}";
then
	echo "Missing source directory: ${SOURCE_DIRECTORY}";

	exit ${EXIT_FAILURE};
fi

cp -rf ${SOURCE_DIRECTORY}/* .;

TEST_FILE="psort_test.json.plaso";

PYTHONPATH=. ./tools/log2timeline.py --buffer_size=300 --quiet ${TEST_FILE} test_data/syslog;
PYTHONPATH=. ./tools/log2timeline.py --quiet --timezone=Iceland ${TEST_FILE} test_data/syslog;

cat > tagging.txt <<EOI
repeated
  body contains 'last message repeated'
EOI

PYTHONPATH=. ./tools/psort.py --analysis tagging --output-format=null --tagging-file=tagging.txt ${TEST_FILE};

# Run tagging twice.
PYTHONPATH=. ./tools/psort.py --analysis tagging --output-format=null --tagging-file=tagging.txt ${TEST_FILE};

mv ${TEST_FILE} ${OLD_PWD}/test_data/;

TEST_FILE="pinfo_test.json.plaso";

PYTHONPATH=. ./tools/log2timeline.py --partition=all --quiet ${TEST_FILE} test_data/tsk_volume_system.raw;

mv ${TEST_FILE} ${OLD_PWD}/test_data/;

cd ${OLD_PWD};

rm -rf ${TEST_DIRECTORY};

