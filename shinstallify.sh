#!/bin/bash

VERSION="0.1"
# v0.1 first release (may contain bugs)

OUTFILE=/dev/stdout
RANDSTR=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 8 | head -n 1)

while getopts "rxbvo:h" OPTION; do
    case $OPTION in
    r)
        RELATIVE=1
        ;;
    b)
        BINARY=1
        ;;
    x)
        XXD=1
        ;;
    v)
        VERBOSE=1
        ;;
    o)
        OUTFILE="$OPTARG"
        ;;
    h)
            echo "Usage: "
            echo
            echo "Example: $0 -o /tmp/installer.sh /etc/myfile /etc/dir /etc/dir/*"
            echo
            echo "Options:"
            echo "-x    Use hex binary compressed mode for files (gzip+xxd)"
            echo "-b    Use binary compressed mode for files (gzip+base64)"
            echo "-r    Save Files with the relative path (otherwise will use realpath)"
            echo "-v    Be Verbose of each written file"
            echo "-o    Output installer (if not specified, will grab to stdout)"
            echo "-h    Show this help"
            echo
            echo "Considerations:"
            echo "  - By now, unless you are using the -b (binary) flag, this will be working leaving a new-line"
            echo "    at every generated file."
            echo "  - Will not recurse into directories, "
            echo "    you should specify each directory first and then their files."
            echo
            echo "Author: Aaron Mizrachi <aaron@unmanarc.com>"
            echo "License: GPLv3"
            echo "Version: $VERSION"
            exit 1
        ;;
    *)
        echo "Incorrect options provided"
        exit 1
        ;;
    esac
done

# Get to file arguments...
shift $(($OPTIND - 1))

if [ "$XXD" = "1" ] && [ "$BINARY" = "1" ]; then
    >&2 echo "# Critical (Choose between -x or -b, not both): Aborting..."
    exit 3
fi

if [ $OUTFILE != "/dev/stdout" ] && [ -e $OUTFILE ]; then
    >&2 echo "# Critical (Output file already exist, aborting): $OUTFILE"
    exit 2
fi

# Default header.
echo "#!/bin/bash" > $OUTFILE

while (($#)); do

    if [ ! -e "$1" ]; then
        >&2 echo "# Warning (File not found): $1"
        shift
        continue
    fi

    FILEPATH=
    if [ "$RELATIVE" = "1" ]; then
        FILEPATH="$1"
    else
        FILEPATH="$(realpath -s $1)"
    fi

    if [[ -L "$FILEPATH" ]]; then
        # Link 
        [ "$VERBOSE" = "1" ] && (>&2 echo "# Creating symlink: $FILEPATH")
        echo "ln -s '$(readlink $FILEPATH)' '$FILEPATH'" >> $OUTFILE
    elif [[ -d "$FILEPATH" ]]; then
        [ "$VERBOSE" = "1" ] && (>&2 echo "# Creating directory: $FILEPATH")
        USER=$(stat -c '%U' $FILEPATH)
        GROUP=$(stat -c '%G' $FILEPATH)
        PERMS=$(stat -c '%a' $FILEPATH)
        echo "install -m '$PERMS' -o '$USER' -g '$GROUP' -d '$FILEPATH'" >> $OUTFILE
    elif [[ -f "$FILEPATH" ]]; then
        [ "$VERBOSE" = "1" ] && (>&2 echo "# Creating file: $FILEPATH")
        USER=$(stat -c '%U' $FILEPATH)
        GROUP=$(stat -c '%G' $FILEPATH)
        PERMS=$(stat -c '%a' $FILEPATH)
        if [ "$BINARY" = "1" ]; then
            echo "cat << 'EOF-$RANDSTR' | base64 -d | gunzip - | install -m '$PERMS' -o '$USER' -g '$GROUP' /dev/stdin '$FILEPATH'" >> $OUTFILE
            cat $FILEPATH | gzip | base64  >> $OUTFILE
        elif [ "$XXD" = "1" ]; then
            echo "cat << 'EOF-$RANDSTR' | xxd -p -r | gunzip - | install -m '$PERMS' -o '$USER' -g '$GROUP' /dev/stdin '$FILEPATH'" >> $OUTFILE
            cat $FILEPATH | gzip | xxd -p  >> $OUTFILE
        else
            echo "cat << 'EOF-$RANDSTR' | install -m '$PERMS' -o '$USER' -g '$GROUP' /dev/stdin '$FILEPATH'" >> $OUTFILE
            cat $FILEPATH >> $OUTFILE
        fi
        echo >> $OUTFILE
        echo "EOF-$RANDSTR" >> $OUTFILE
    else
        (>&2 echo "# Error (Unsupported file type): $FILEPATH")
    fi

    shift
done

echo "# DONE." >> $OUTFILE

exit 0;