#! /bin/bash
VERSION=1.3.0
LIB_NAME=mongrel
BUILD_NAME=$LIB_NAME-$VERSION

make_failed()
{
    rm -r $BUILD_NAME
    echo $1
    exit 1
}

# If an archive already exists, delete it.
if ls $LIB_NAME-*.zip >/dev/null 2>/dev/null
then
    rm $LIB_NAME-*.zip
fi

# Create directories for the build artifacts.
mkdir $BUILD_NAME
mkdir $BUILD_NAME/doc
mkdir $BUILD_NAME/ebin
mkdir $BUILD_NAME/tbin

# Compile the source and the tests to separate binary directories.
echo "Compiling..."
if ! erlc -I include -o $BUILD_NAME/ebin src/*.erl 
then
    make_failed "Compilation failed."
fi
cp src/$LIB_NAME.app.src $BUILD_NAME/ebin/$LIB_NAME.app
if ! erlc -I include -o $BUILD_NAME/tbin test/*.erl
then
    make_failed "Tests couldn't be compiled."
fi

# Run all the tests.
echo "Running tests..."
if ! erl -noshell -pa $BUILD_NAME/ebin -pa $BUILD_NAME/tbin -s test_all test $BUILD_NAME/tbin -s init stop
then
    make_failed "Not all tests passed."
fi

# We don't need to keep the test binaries.
rm -r $BUILD_NAME/tbin

# Create the EDocs.
echo "Generating EDocs..."
cp doc/overview.edoc $BUILD_NAME/doc
if ! ./gen_doc.sh $BUILD_NAME/doc
then
    make_failed "Errors while generating EDocs."
fi

# Copy source files into the artifacts directory.
rsync -p -r --exclude=".*" src $BUILD_NAME
rsync -p -r --exclude=".*" test $BUILD_NAME
rsync -p -r --exclude=".*" include $BUILD_NAME
rsync -p -r --exclude=".*" src_examples $BUILD_NAME
cp make_mongrel.sh $BUILD_NAME
cp gen_doc.sh $BUILD_NAME
cp releases.txt $BUILD_NAME

# Zip it all up.
echo "Packaging..."
zip -q $BUILD_NAME.zip -r $BUILD_NAME
#tar cjf $BUILD_NAME.tar.gz $BUILD_NAME
rm -r $BUILD_NAME

echo "OK."
exit 0

