#!/bin/bash

begin(){
declare -a key_array
declare -a uid_array
key_count=0

if gpg --list-secret-keys --keyid-format LONG | grep -q sec 
then
    echo "OK! so you want to use a GPG key right! Well here are some options for you :-"
    main
else 
    echo "OK! so you want to use a GPG key right! You don't have any existing keys yet!! Wanna generate a new key? [y for YES/ n for NO]"
    read decision
    if [$decision == "y"]
        then generate_key
    elif [$decision == "n"]
        then 
            echo "Okay, then exiting!!!"
            exit
    else
        echo "OK! I am gonna take it as a No! Bye!!!"
        exit
    fi
fi
}

main(){
echo "
1. Use existing GPG key
2. Generate new GPG key
3. EXIT !!!"
read n
if [[ $n -eq 3 ]]
    then
        exit
elif [[ $n -eq 2 ]]
    then
        generate_key
elif [[ $n -eq 1 ]]
    then
        existing_key
else
    echo "Invalid Input, Try Again !!!"
    main
fi
}
generate_key(){
gpg --full-generate-key
echo "Your new GPG key is generated !!!"
existing_key
}
existing_key(){
echo "Here is a list of your current keys :-"
key=$(gpg --list-secret-keys --keyid-format=long|awk '/sec/{if (length($2)>0) print $2}')
uid=$(gpg --list-secret-keys --keyid-format=long|awk '/uid/')
key_len=${#key}
uid_len=${#uid}

key_count=0
for ((i=0;i<key_len;i++));
do
if [[ ${key:$i:1} == "/" ]]
then
key_array[$key_count]=${key:$i+1:16}
((key_count++))
fi
done

uid_count=0
uid_start=0
uid_end=0
for ((i=0;i<uid_len;i++))
do
if [[ ${uid:$i:1} == ']' ]] 
        then
            uid_start=$i+1
        fi
        if [[ ${uid:$i:1} == ">" ]] 
        then
            uid_end=$i+1
            uid_array[$uid_count]=${uid:$uid_start+1:$uid_end-$uid_start}
            ((uid_count++))
        fi
done

c=0
for ((i=0;i<uid_count;i++))
do
c=$((i+1))
echo "${c}) ${uid_array[$i]}"
done

echo "Enter your key no. to choose one of these existing keys!"
read kn
if [ $kn -le $key_count ]
    then
        git config --global user.signingkey ${key_array[$((kn-1))]}
        git config --global commit.gpgsign true
        echo "Your key is succesfully set!!!"
else
        echo "No such key!!! Wanna try again? (y for YES/n for NO)"
        read decision
        if [ $decision == "y" ]
            then existing_key
        elif [ $decision == "n" ]
            then exit
        else
            echo "OK! I am gonna take it as a No! Bye!!!"
            exit
        fi
fi
}
begin