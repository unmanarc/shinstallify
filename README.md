# SHinstallify 

 A tool for creating script to backup/restore config/files/dir's on *nix with bash
  
Author: Aaron Mizrachi (unmanarc) <aaron@unmanarc.com>   
License: GPLv3   

***

## Purporse:

We frequently create configurations on our servers and need to transform them into a format that we can use to restore them. In that case, the most common and accepted strategy is to use `tar`, which will record all the information in a standard and compatible format.

However, we do not always have access to some file transfer mechanism to get the configuration files, eg. sometimes we are pivoting on a host bastion, and it complicates exfiltration of the file or even complicates putting the file in its place on the new server.

That is why transforming these files into a bash file that can be copied/&/pasted through the SSH console can be very useful.

Bash is in almost every *nix server these days, so the compatibility should be transparent.

## Installation:

You can download the latest sh file with wget (or cloning this repo):

```
wget https://raw.githubusercontent.com/unmanarc/shinstallify/master/shinstallify.sh
chmod +x ./shinstallify.sh
```

## Usage:

```
# ./shinstallify.sh -h

Usage: 

Example: ./shinstallify.sh -o /tmp/installer.sh /etc/myfile /etc/dir /etc/dir/*

Options:
-b    Use binary compressed mode for files (gzip+base64)
-r    Save Files with the relative path (otherwise will use realpath)
-v    Be Verbose of each written file
-o    Output installer (if not specified, will grab to stdout)
-h    Show this help

Considerations:
  - By now, unless you are using the -b (binary) flag, this will be working leaving a new-line 
    at every generated file.
  - Will not recurse into directories, 
    you should specify each directory first and then their files.

Author: Aaron Mizrachi <aaron@unmanarc.com>
License: GPLv3
Version: 0.1
```

## Disclaimer:

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Bug reports:

This is in a very alpha status, which means that may contain a lot of bugs, please if you found one report it via github.
