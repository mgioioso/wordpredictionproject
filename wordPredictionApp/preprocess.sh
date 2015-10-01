# replace numbers with tokens
# replace words with first letter cap to all lower case
# replace characters that are repeated 3 or more times with one occurrence
# of that character
#----------
# remove smiley faces
# replace w/ with with
# replace / with 'and'
# replace two or more hyphens in a row OR ' - ' OR [?!.:;] with newline
# replace single quote by itself or at beginning or end of a word with newline
# remove punction: $ % @ # * < > , / \ "
# remove blank lines

iconv -c -f utf-8 -t ascii < ../data/en_US/en_US.twitter.txt\
| tr '\32' ' '\
| sed -r 's/([0-9]+([,.][0-9]+)*)/\n/g'\
| sed -r 's/([A-Z])/\L\1/g'\
| sed -r 's/(.)\1{2,}/\1/g'\
| sed -r 's/[:;]-*[\)\(PpD\/]*//g'\
| sed -r 's| w/| with |g'\
| sed -r 's|[&+/]| and |g'\
| sed -r 's|=| equals |g'\
| sed -r 's/[?!.:;()]/\n/g'\
| sed -r 's|[$%@#*<>,/\\"_]||g'\
| sed -r 's/(\[|\]|\{|\})//g'\
| sed -r "s/(\b' | '\b| ' )/\n/g"\
| sed -r 's/\-\-| *\- /\n/g'\
| sed -r 's/  +/ /g' | sed -r 's/^ +| +$//g'\
| sed -r '/^$|^.$/d' > ../data/sample/en_US.twitter.sample5.txt

echo 'Preprocessed twitter...'

iconv -c -f utf-8 -t ascii < ../data/en_US/en_US.blogs.txt\
| tr '\32' ' '\
| sed -r 's/([0-9]+([,.][0-9]+)*)/\n/g'\
| sed -r 's/([A-Z])/\L\1/g'\
| sed -r 's/(.)\1{2,}/\1/g'\
| sed -r 's/[:;]-*[\)\(PpD\/]*//g'\
| sed -r 's| w/| with |g'\
| sed -r 's|[&+/]| and |g'\
| sed -r 's|=| equals |g'\
| sed -r 's/[?!.:;()]/\n/g'\
| sed -r 's|[$%@#*<>,\\"_]||g'\
| sed -r 's/(\[|\]|\{|\})//g'\
| sed -r "s/(\b' | '\b| ' )/\n/g"\
| sed -r 's/\-\-| *\- /\n/g'\
| sed -r 's/  +/ /g' | sed -r 's/^ +| +$//g'\
| sed -r '/^$|^.$/d' > ../data/sample/en_US.blogs.sample5.txt

echo 'Preprocessed blogs...'

iconv -c -f utf-8 -t ascii < ../data/en_US/en_US.news.txt\
| tr '\32' ' '\
| sed -r 's/([0-9]+([,.][0-9]+)*)/\n/g'\
| sed -r 's/([A-Z])/\L\1/g'\
| sed -r 's/(.)\1{2,}/\1/g'\
| sed -r 's/[:;]-*[\)\(PpD\/]*//g'\
| sed -r 's| w/| with |g'\
| sed -r 's|[&+/]| and |g'\
| sed -r 's|=| equals |g'\
| sed -r 's/[?!.:;()]/\n/g'\
| sed -r 's|[$%@#*<>,\\"_]||g'\
| sed -r 's/(\[|\]|\{|\})//g'\
| sed -r "s/(\b' | '\b| ' )/\n/g"\
| sed -r 's/\-\-| *\- /\n/g'\
| sed -r 's/  +/ /g' | sed -r 's/^ +| +$//g'\
| sed -r '/^$|^.$/d' > ../data/sample/en_US.news.sample5.txt

echo 'Preprocessed news...'

