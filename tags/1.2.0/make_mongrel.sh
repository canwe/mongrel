#! /bin/bash
VERSION=1.2.0
BUILD_NAME=mongrel-$VERSION

# If the archive already exists, delete it
if [ -f $BUILD_NAME.zip ]
then
    rm $BUILD_NAME.zip
fi

# Create directories for the build artifacts
mkdir $BUILD_NAME
mkdir $BUILD_NAME/doc
mkdir $BUILD_NAME/ebin
mkdir $BUILD_NAME/tbin

# Compile the source and the tests to separate binary directories
echo "Compiling..."
erlc -I include -o $BUILD_NAME/ebin src/*.erl
cp src/*.app $BUILD_NAME/ebin
erlc -I include -o $BUILD_NAME/tbin test/*.erl

# Run all the tests
echo "Running tests..."
erl -noshell -pa $BUILD_NAME/ebin -pa $BUILD_NAME/tbin -s test_all test $BUILD_NAME/tbin -s init stop
if [ $? -ne 0 ]
then
    rm -r $BUILD_NAME
    echo "Not all tests passed."
    exit 1
fi

# We don't need to keep the test binaries
rm -r $BUILD_NAME/tbin

# Create the EDocs
echo "Generating EDocs..."
cp overview.edoc $BUILD_NAME/doc
./gen_doc.sh $BUILD_NAME/doc

# Copy source files into the artifacts directory
rsync -p -r --exclude=".*" src $BUILD_NAME
rsync -p -r --exclude=".*" test $BUILD_NAME
rsync -p -r --exclude=".*" include $BUILD_NAME
rsync -p -r --exclude=".*" src_examples $BUILD_NAME
cp make_mongrel.sh $BUILD_NAME
cp gen_doc.sh $BUILD_NAME
cp releases.txt $BUILD_NAME

# Remove some cruft
rm $BUILD_NAME/doc/overview.edoc
rm $BUILD_NAME/doc/edoc-info
cp overview.edoc $BUILD_NAME

# Zip it all up.
echo "Packaging..."
zip -q $BUILD_NAME.zip -r $BUILD_NAME
#tar cjf $BUILD_NAME.tar.gz $BUILD_NAME
rm -r $BUILD_NAME

echo "OK."
exit 0

