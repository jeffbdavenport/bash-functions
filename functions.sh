alias ld='find . -maxdepth 2 -type d'
export LC_ALL="en_AU.UTF-8"
alias wp='/usr/php/54/usr/bin/php-cli /usr/local/bin/wp'
alias ls='/bin/ls --color=tty -F -A -b -T 0 --group-directories-first'
alias ll='ls -lah'
alias dg='dig2'
alias lsf='find `pwd` -maxdepth 1 -type f | sort'
alias vi='vic'
alias vic='vim -c "nnoremap n h|nnoremap e j|nnoremap u k|nnoremap i l|nnoremap l i|nnoremap h n|nnoremap k u|nnoremap j e|vnoremap n h|vnoremap e j|vnoremap u k|vnoremap i l|vnoremap l i|vnoremap h n|vnoremap k u|vnoremap j e"'
alias rnew='taskset -c 0-2 ~/bin/runit -jar'
bind '"\C-t": reverse-search-history'
TERM=xterm
function dshort(){
cat <<'EOF' > ~/.local/share/applications/short
[Desktop Entry]
Encoding=UTF-8
Version=1.0                                     # version of an app.
Name[en_US]=yEd                                 # name of an app.
GenericName=GUI Port Scanner                    # longer name of an app.
Exec=java -jar /opt/yed-3.11.1/yed.jar          # command used to launch an app.
Terminal=false                                  # whether an app requires to be run in a terminal.
Icon[en_US]=/opt/yed-3.11.1/icons/yicon32.png   # location of icon file.
Type=Application                                # type.
Categories=Application;Network;Security;        # categories in which this app should be listed.
Comment[en_US]=yEd Graph Editor                 # comment which appears as a tooltip.
EOF
}

wget -Oq ~/tmp/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x ~/tmp/wp
alias wp='~/tmp/wp'

function resetwp {
	if [[ -f wp-config.php ]];then
		read db user pass host prefix <<< $(egrep -o '(DB_[NUPH]|_prefix)[^;]+' wp-config.php|grep -Po "[^'\"]+(?=(['\"]\)|[\"'])$)");
		mysql -u "$user" -p"$pass" -h "$host" "$db" -e "UPDATE ${prefix}users SET user_pass=MD5('$2') WHERE ID=$1;" && echo "User $1 set to $2";
	else
		echo "wp-config not found"
		return 1;
	fi
}
function mwcheck {
	wget -q http://74.220.215.202/~toshmtes/TempGrep/standalone.txt -O - | sh >> malware.txt;
}
function wptool(){
  . <(curl -sS https://bitbucket.org/petershaw_org/wptool/raw/0d190fac415b0e45d1e25c2c6e5de79bd152a6e6/wptool)
}
function fuse(){
        for dir in `find -maxdepth 1 -type d`;do echo "`find $dir -printf x|wc -c`: $dir";done|sed "s#//##"|sort -n
}

function ckswap(){
for pid in `ps auxH|awk '{print $2}'`;do echo "Pid: $pid" && egrep -i '(swap|size|pid|/|\[)' /proc/$test/smaps ;done|egrep -v '[04] kB'|grep -Pzo "^(Pid[^\n]*|(?s:[^\n]*$.Swap[^\n]*$){2})"
}
function lsofp(){
	  while true;do sleep 0.5;for test in `ps aux|egrep $1|awk '{print $2}'`;do lsof -p $test| grep "$HOME";done;done
}
function nethead(){
	ips=$(ss -tuna|egrep -v '(LISTEN|UNCON)'|sed 1d|awk '{print $5" "$6}'|egrep -o '[0-9]++ [:f]*[0-9]+\.[0-9.]+'|sort)
	echo "$ips"|uniq -c|sort -n
        echo "Ports:"
        echo "$ips"|awk '{print $1}'|uniq -c|egrep '\s[1-2]?[0-9]{1,3}$'
        echo "Top IPs:"
	for test in `echo "$ips"|uniq -c|sort -n|awk '{print $3}'|tail -n 6`;do
	  dig_res=$(dig -x $test +short|head -n 1)
	  echo -e "$test\t$dig_res"
	done
	  
}
function checkbk(){
for user in `egrep -o '^[^:]+' /etc/passwd`;do ll -d /backup/cpbackup/{daily,weekly}/$user.tar{,.gz} 2>/dev/null;done
}
function fixetime(){
#replace last modified date on emails in current folder to match the filename timestamp
  for file in `ls`;do file=$(echo "$file"|sed "s/\\\//g");test=$(echo $file|sed "s/\(^.\{10\}\).*/\1/");touch -md "$(date -d@${test})" "$file";done
}

function sarall(){
#show sar reports from all files at once.
local OPTIND flag n q
list=$(ls -tr /var/log/sa/sa[0-9]*|tail -n 10)
arg=""
while getopts 'n:qa' flag; do
  case "${flag}" in
    n) list=$(ls -tr /var/log/sa/sa[0-9]*|tail -n ${OPTARG});;
    a) list=$(ls -tr /var/log/sa/sa[0-9]*);;
    *) arg="$arg${flag}";;
  esac
done
shift $((OPTIND-1))
arg="-$arg"
for test in $list;do sar $arg -f "$test" 2>/dev/null|egrep -i '(^[0-9]{2}:(00|15|30|45)|av|CPU|^$)';done
}

function fss(){
#find script spam
  grep cwd /var/log/exim_mainlog | grep -v /var/spool | awk -F"cwd=" '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n
}

function wpcore(){
#replace core wordpress files with the current version
if [ "$1" == 'cur' ];then
    ver=$(sed '7q;d' ./wp-includes/version.php|egrep -o '[0-9.]+');if [ $(ls -d "./wordpress-$ver.tar.gz" ./wordpress.bak 2>/dev/null|wc -l) -gt 0 ];then ls -d ./latest.tar.gz ./wordpress.bak 2>/dev/null;echo "The above files exist, please rename them first.";else wget "https://wordpress.org/wordpress-$ver.tar.gz" && mkdir wordpress.bak &&  mv ./wp-admin ./wp-includes ./wordpress.bak 2>/dev/null && tar --strip-components=1 -xf wordpress-"$ver.tar.gz" && rm -Rf "./wordpress-$ver.tar.gz" ./wordpress;fi
else
    if [ $(ls -d ./wordpress ./latest.zip ./wordpress.bak 2>/dev/null|wc -l) -gt 0 ];then ls -d ./wordpress ./latest.zip ./wordpress.bak 2>/dev/null;echo "The above files exist, please rename them first.";else wget https://wordpress.org/latest.zip && mkdir wordpress.bak &&  mv ./wp-admin ./wp-includes ./wordpress.bak 2>/dev/null && unzip ./latest.zip && mv -f ./wordpress/* ./ 2>/dev/null;rm -Rf ./latest.zip ./wordpress;fi
fi

}


function fconfig(){
#search all *(config|db)*\.php files for databases and show them in a list with the files.
findConfig=$(grep -riEo -m 1 --include "*config*\.php" --include "*db*\.php" "(db|database).*$USER"_"[a-zA-Z0-9_-]+" ~/public_html | sed "s/^\(.*:\).*\('\|\"\)\(.*\)/\3: \1/" | sort)
echo -e "$findConfig\n\nHere are the databases used:\n" | sed "s/^\(.\{1,14\}:\)/\1\t\t/g;s/^\(.\{15,22\}:\)/\1\t/g"
echo "$findConfig" | sed "s/:.*$//g" | uniq 
}


function cssftp(){
#remove SS accounts from cPanel (must also be removed from /etc )
sed -i 's#{\(\("user":"ss-[0-9a-z]\+"\|"type":"sub"\|"homedir":"/home[0-9]\{1,2\}/[a-z0-9]\{8\}\(/tmp/simplescripts\)\?"\),\?\)\+},\?##g' ~/.cpanel/datastore/ftp_LISTSTORE
}

function dig2(){
#dig the A record, www, the PTR for the a record, the MX , SPF, and NS records.
  result=$(/usr/bin/dig +time=1 "$@" +noquestion +noadditional +nostats +nocomments +noauthority | sed '/^;/d')
  result2=$(/usr/bin/dig +time=1 "www.$@" +noquestion +noadditional +nostats +nocomments +noauthority | sed '/^www\./!d' )
  echo -e "$result\n$result2"
  echo -en "\nIP rDNS: "
  result5=$(/usr/bin/dig +time=1 "$1" +short)
  result3=$(/usr/bin/dig -x $result5 +time=1 +short)
  echo "$result3  $result5"
  echo -e "\nMX: "
  /usr/bin/dig "$@" mx +short +time=1
  echo -e "\nSPF: "
  /usr/bin/dig "$@" txt +short +time=1
  echo -e "\nNS: "
  result4=$(/usr/bin/dig "$@" ns +short +time=1)
  echo -e "$result4\n"
  if [[ $result3 =~ bluehost ]]; then 
    echo -ne "\n@BH: "
    /usr/bin/dig @ns1.bluehost.com "$@" +short +time=1
  elif [[ $result3 =~ justhost ]]; then
    echo -n "@JH: "
    /usr/bin/dig @ns1.justhost.com "$@" +short +time=1
  elif [[ $result3 =~ hostmonster ]]; then
    echo -n "@HM: "
    /usr/bin/dig @ns1.hostmonster.com "$@" +short +time=1
  elif [[ $result3 =~ fastdomain ]]; then
    echo -n "@FD: "
    /usr/bin/dig @ns1.fastdomain.com "$@" +short +time=1
  elif [[ $result4 =~ bluehost ]]; then 
    echo -ne "\n@BH: "
    /usr/bin/dig @ns1.bluehost.com "$@" +short +time=1
  elif [[ $result4 =~ justhost ]]; then
    echo -n "@JH: "
    /usr/bin/dig @ns1.justhost.com "$@" +short +time=1
  elif [[ $result4 =~ hostmonster ]]; then
    echo -n "@HM: "
    /usr/bin/dig @ns1.hostmonster.com "$@" +short +time=1
  elif [[ $result4 =~ fastdomain ]]; then
    echo -n "@FD: "
    /usr/bin/dig @ns1.fastdomain.com "$@" +short +time=1
  else
    echo -ne "\n@BH: "
    /usr/bin/dig @ns1.bluehost.com "$@" +short +time=1
    echo -n "@JH: "
    /usr/bin/dig @ns1.justhost.com "$@" +short +time=1
    echo -n "@HM: "
    /usr/bin/dig @ns1.hostmonster.com "$@" +short +time=1
  fi
}

function phpinfo(){
#create a phpinfo page if it doesnt exist
  if [ ! -f ./info.php ]; then
     echo '<?php phpinfo(); ?>' > ./info.php
  else
    echo "There is already an info.php"
  fi
}

function fwperms(){
#Give write permission to all directories or all files for user
	if [[ $1 =~ ^-[^a]$ ]]; then
	  echo "$1 is not a valid option."
	  return 1
	elif [[ $1 =~ ^-(a?([^a]a?)){2,} ]]; then
	  echo -ne "-"
	  echo -ne "$1" | sed -E 's/-?([a-zA-Z0-9])/\1\n/g' | sort | tr '\n' ' ' | sed -E 's/ //g;s/(.)[^\1]*\1/\1/g;s/a//g' 
	echo " are not valid options."
	  return 1
	fi
	echo "Giving write permission to every dir for user";
	done=0
	find2perl . -type d ! -perm -500 -exec chmod -c u+rx */ {} | perl && done=1
	while [ $done -eq 0 ];
	do
	  find2perl . -type d ! -perm -500 -exec chmod -c u+rx */ {} | perl && done=1
	done
	find2perl . ! -perm -200 -type d -exec chmod -c u+w {} | perl
	if [[ $1 =~ ^-.*a ]]; then
		find2perl . ! -perm -200 -type f -exec chmod -c u+w {} | perl
	fi
	echo "Done."
}

function fmailperms(){
  chmod -c 751 ~/mail
  chmod -c 750 ~/etc
  find2perl ~/etc ! -perm 750 -type d -exec chmod -c u+rwx,go-w,o-rx {} | perl
  find2perl ~/mail ! -perm 751 -type d -exec chmod -c u+rwx,go-w,o-r {} | perl
  find2perl ~/etc ! -perm 640 -type f -exec chmod -c u+rw,go-w,o-rx {} | perl
  echo "Fixing ~/mail/ file perms..."
  find2perl ~/mail ! -perm 640 -type f -exec chmod -c u+rw,go-w,o-x {} | perl
  echo "Done."
}


function fpermsh(){
#fix permissions by giving execute and read permission to directories and removing write permission from group and other
#and adding read permission to files and removing write permission from group and other
	echo "Fixing the permissions."
	chmod -c uo+rx ~/public_html 2>/dev/null
	chmod -c uo+rx . 2>/dev/null
	done=0
	find2perl . -type d ! -perm -500 -exec chmod -c u+rx */ {} | perl && done=1
	while [ $done -eq 0 ];
	do
	  find2perl . -type d ! -perm -500 -exec chmod -c u+rx */ {} | perl && done=1
	done
	
	for i in `find2perl ./ -perm -020 -type d | perl 2>/dev/null | sed "s/ /#$%/g"`; do 
	j=$(echo $i | sed "s/#$%/ /g")
		 ls "$j"/*.[pj][sh]? 2>/dev/null && chmod -c uo+xr,go-w "$j"
	done
	for i in `find2perl ./ -perm -002 -type d | perl 2>/dev/null | sed "s/ /#$%/g"`; do 
	j=$(echo $i | sed "s/#$%/ /g")
		 ls "$j"/*.[pj][sh]? 2>/dev/null && chmod -c uo+xr,go-w "$j"
	done
	for i in `find2perl ./ ! -perm -505 -type d | perl 2>/dev/null | sed "s/ /#$%/g"`; do 
	j=$(echo $i | sed "s/#$%/ /g")
		 ls "$j"/*.[pj][sh]? 2>/dev/null && chmod -c uo+xr,go-w "$j"
	done
	
	find2perl ./ -perm -002 -name \*.[pj][sh]? -type f -exec chmod -c uo+r,go-w {} | perl
	find2perl ./ -perm -020 -name \*.[pj][sh]? -type f -exec chmod -c uo+r,go-w {} | perl
	find2perl ./ ! -perm -404 -name \*.[pj][sh]? -type f -exec chmod -c uo+r,go-w {} | perl
	
	echo "Done"
}
function fperms(){
#lightly try to fix permissions by only removing write permission from group and other on php and js files
	echo "Fixing the permissions."
	chmod -c uo+rx . 2>/dev/null
	for i in `find2perl ./ -perm -020 -type d 2>/dev/null | perl 2>/dev/null | sed "s/ /#%/g"`; do 
	  j="$(echo $i | sed "s/#%/ /g")"
	  ls "$j"/*.[pj][sh]? 2>/dev/null 2>/dev/null && chmod -c go-w "$j"
	done
	for i in `find2perl ./ -perm -002 -type d 2>/dev/null | perl 2>/dev/null | sed "s/ /#%/g"`; do 
	 j="$(echo $i | sed "s/#%/ /g")"
	 ls "$j"/*.[pj][sh]? 2>/dev/null 2>/dev/null && chmod -c go-w  "$j"
	done
	
	
	find2perl ./ -perm -020 -perm -404 -name \*.[pj][sh]? -type f -exec chmod -c go-w {} | perl 2>/dev/null
	find2perl ./ -perm -002 -perm -404 -name \*.[pj][sh]? -type f -exec chmod -c go-w {} | perl 2>/dev/null
	
	echo "Done"
}


function errl(){
#search for error logs last modified in the last 10 days in the current directory tree and tail the last 10/50 lines in them.
if [[ $1 =~ ^-a$ ]]; then
  find2perl ./ -name error_log -type f -exec tail -50 {} | perl | egrep -i "2015"
elif [ $1 ]; then
  find2perl ./ -name error_log -mtime -30 -type f -exec tail -50 {} | perl | egrep -i "2015.*$1"
else
  find2perl ./ -name error_log -mtime -10 -type f -exec tail -10 {} | perl | grep "2015"
fi
echo "There are $(find -name error_log -type f -printf x 2>/dev/null | wc -c) error logs"
}

function inodes(){
if [ ! $1 ]; then 
  search="."
else
  search="$1"
fi
find $search -xdev -printf "%h\n" | sort | uniq -c | sort -rn | head
}

function duse(){
  dir='.'
  lines='20'
  if [ -e "$1" ];then
    dir="$1"
  else
    if [[ $1 =~ ^[0-9]+$ ]];then
      lines="$1"
    fi
  fi
  if [ -e "$2" ];then
    dir="$2"
  else
    if [[ $2 =~ ^[0-9]+$ ]];then
      lines="$2"
    fi
  fi
  du -xh "$dir"|sort -h|tail -"$lines"
}

function dbconfig(){
    egrep "DB_(NAME|USER|PASSWORD[^_])|table_prefix" wp-config.php | sort -d | sed "s/.*[\"']\(.*\)[\"'].*;.*/\1/"
}

function cmds(){
echo -e "These are the available commands:
\n
\nfwperms\t adds write permission for only "User" to every file and folder in the current directory.
faperms\t Adds execute and read permissions to all folders and read permissions to all files in the current directory.
fpermsh\t Only adds execute and read permissions to folders if there is a php file in it, and will add read permssion to all files that end in .php.
fmailperms\t Corrects any bad mail permissions.
filec\t Counts the files and directories in the current directory.
duse\t Outputs a list of the largest folders and files in the current directory.
dpub\t Outputs a list of the largest folders and files in public_html.
errl\t Searches the current folder for any error logs with errors for this month.
intd\t Gets a list of all possible email accounts to find the spam email account.
sslp\t Checks what SSL certificates are on the server and you can output the certificate information and CA.
fspam\t Outputs the file named findspam and searches it for all email addresses and user names and sorts it by the who sent the most emails.
ips\t Shows the blackholed IPs.
swf\t Find revslider hack.
cssftp
fconfig

ext\t Extracts any file.
cmds\t Displays these commands.
"
}

function fspam(){
#parse exim logs to check who sent how many emails
grep -Po 'U=[a-z0-9]{6,8}' [Ff]ind[Ss]pam | sort | uniq -c | sort -n | sed "s/= //;s/U=/User: /" | tail -10 | sed '/mailnull/d'
grep -Po 'U=mailnull.* for [a-zA-Z-._@+]+$' [Ff]ind[Ss]pam | sed -E "s/U=mailnull.*for //g" | sort | uniq -c | sort -n | tail -20
grep -Po '((= |A=dovecot_login:|F=<)[-a-zA-Z0-9_.]+[@+][a-zA-Z0-9-.]+)' [Ff]ind[Ss]pam | sed -E "s/[HFA]?=([< ]|dovecot_login:)//g" | sort | uniq -c | sort -n | sed '/(root@[hjbf]|mailnull)/d' | tail -30
}

function ext()      
# Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.xz)        tar xvJf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

function ips(){
#easy listing for the blackhole list
  list=$(ip route show | grep blackhole)
  if [ -z $1 ]; then
    echo "These are the blackholed IPs:"
    echo "$list"
  elif [[ $1 =~ ^((25[0-5]|(2[0-4]|1[0-9]|[0-9]?)[0-9])(\.|$)){1,4}$ ]]; then
    search=$(echo "$1" | sed "s/\(\([0-9]\+\.\)\{2\}\).*/\1/")
    echo "These are all the blackholed IPs"
    echo "$list"
    if [[ $search =~ ^[0-9.]+$ ]];then
      echo -e "\nHere is the Network: $search"
      echo "$list" | grep "$search"
    fi
    echo -e "\nHere is your search:"
    echo "$list" | grep $1
  else
    echo "That is not a valid IP address"
  fi
}

function sslp(){
script=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/sslperl);md5=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/sslperl.md5);if [[ $(echo "$script"|md5sum| cut -d' ' -f1) == "$md5" ]]; then perl <(echo "$script");else echo "MD5Hash failed, dying";fi;
}
function sslt(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/perl/sslperlfix)
#test "$(echo "$s"|md5sum)" == '1b758abd5a1b0005c6e10c17f205fb2b  -' && 
perl <(echo "$s") "$@"
}

function cmcheck(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/cmcheck)
test "$(echo "$s"|md5sum)" == '6f9c9c835471254bbd7b80f5bc1c3d6f  -' && . <(echo "$s") "$@"
}

function intd(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/internaldomains)
test "$(echo "$s"|md5sum)" == 'ef3123744b95662e2a848ad5a871badb  -' && . <(echo "$s") "$@"
}

function wpinst(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/installwordpress)
test "$(echo "$s"|md5sum)" == '2243df5296f1c92c8557f44652932f29  -' && . <(echo "$s") "$@"
}

function wpvelv(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/velvinstall)
test "$(echo "$s"|md5sum)" == '581b884e9bd7b3f00bc179377f839990  -' && . <(echo "$s") "$@"
}
function filec(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/perl/filec)
test "$(echo "$s"|md5sum)" == '28c643cf16555eb665fc3d04de68f908  -' && perl <(echo "$s") "$@"
}
function quickc(){
s=$(curl -sS http://jdavenport.bluehoststaff.com/scripts/perl/quickc)
test "$(echo "$s"|md5sum)" == '57c6194d1400487110a4da71f3c9055b  -' && perl <(echo "$s") "$@"
}
cmds
