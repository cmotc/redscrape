#! /usr/bin/env sh
export TRIMFRONT='<a class="title may-blank " href="'
export TRIMFRONT2='<a href="'
#URLSTRINGS=$(cat channellists/*)
DEFAULTSTR=$HOME/Videos/URLS
URLLISTDIR=urllists
REDDITURLS=https://reddit.com
FILESTYPES="webm mkv flv vob ogg ogv avi asf mp4 m4v mpg mpeg mpv 3gp 3g2 m3u asx pls xspf html"
GREPCOMMAND="grep"
if [ -f /etc/redscrape.conf ]; then
        . /etc/redscrape.conf
fi
if [ -f $HOME/.rscrc ]; then
        . $HOME/.rscrc
elif [ -f $HOME/.config/rscrc ]; then
        . $HOME/.config/.rscrc
fi
for TYPE in $FILESTYPES; do
        GREPCOMMAND="$GREPCOMMAND -e $TYPE "
done
URLSTRINGS=$(cat $URLLISTDIR/*.list)
echo "Looking for files like this: $GREPCOMMAND"
rm -rf $DEFAULTSTR/*
if [ ! -d $DEFAULTSTR ]; then
        mkdir -p $DEFAULTSTR
fi
for URL in $URLSTRINGS; do
        echo "Checking subreddit: $URL"
        TOPICSTRINGS=$(wget -q -O - https://www.reddit.com/r/NHLStreams/ \
                | sed 's/</\'$'\n</g' \
                | grep -i "<a" \
                | grep -i "href" \
                | grep -i "title" \
                | grep -v "moderator" \
                | grep -oP "^$TRIMFRONT\K.*" \
                | cut -f1 -d '"')
        for TOPIC in $TOPICSTRINGS; do
                echo "Checking thread: $TOPIC
                ($REDDITURLS$TOPIC)"
                SAVE=$(echo $TOPIC | tr -d "/")
                LINKSTRINGS=$(wget -q -O - "$REDDITURLS$TOPIC" \
                | sed 's/</\'$'\n</g' \
                | grep -i "<a" \
                | grep -i "href" \
                | grep -v "moderator" \
                | grep -v "reddit.com/" \
                | grep -v "javascript" \
                | grep -v "play.google.com" \
                | grep -v "itunes.apple.com" \
                | grep -v "reddit.zendesk.com" \
                | grep -v "redditgifts.com" \
                | grep -v "/advertising" \
                | grep -v "/newsletter" \
                | grep -v "reset password" \
                | grep -v "c-btn c-btn-primary" \
                | grep -v "mweb-redirect-btn choice" \
                | grep -v "/gold" \
                | grep -v "data-event-action=\"parent\" class=\"bylink\" rel=\"nofollow\" >parent" \
                | grep -v "cakeday" \
                | grep -v "read-next-link may-blank" \
                | grep -v "option" \
                | grep -v " href=\"/r/" \
                | grep -v " href=\"/u/" \
                | grep -oP "^$TRIMFRONT2\K.*" \
                | cut -f1 -d '"')
                echo $LINKSTRINGS | tr " " "\n" > "$DEFAULTSTR/$SAVE.txt"
                for LINK in $LINKSTRINGS; do
                        for TYPE in $FILESTYPES; do
                                if [ $(echo $LINK | grep -i $TYPE) ]; then
                                        if [ ! -d $DEFAULTSTR/$TYPE ]; then
                                                mkdir -p $DEFAULTSTR/$TYPE
                                        fi
                                        if [ -f $DEFAULTSTR/$TYPE/$SAVE.txt ]; then
                                                rm $DEFAULTSTR/$TYPE/$SAVE.txt
                                        fi
                                        echo $LINK > $DEFAULTSTR/$TYPE/$SAVE.txt
                                fi
                        done
                done
        done
done