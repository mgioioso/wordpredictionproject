Capstone Word Prediction Application
========================================================
author: Marisa Gioioso
date: August 16, 2015
font-family: 'Helvetica'
transition: rotate

The Need for Word Prediction
========================================================

Next word prediction is used extensively in the interaction
between humans and machines, such as:

- Word completion of natural language input for search apps
- Aid to user typing on a phone keyboard to speed up input

Some issues that make this problem complex:
- Sentences can have complex structure with multiple phrases
- The English language has a plethora of irregular words

Yet, fairly good word prediction can be achieved
by using only a few prior words in the phrase as predictors
 for the next word.

Introducing the Word Prediction App
===================================== 

The word prediction app consists of:
- A text box in which the user can enter a phrase
- A button to enable prediction once the complete phrase has been entered
- A Select box, displaying the word that the app finds the most likely next word. 
    - When the choice box is selected, other highly likely words can also be viewed
- A word cloud graphically displaying the most likely words

The ability to select from a list of likely words gives the user options for next words.


Approach
========================================================

The app is using a typical approach to word prediction, namely:
- Clean an input data set of phrases taken from Twitter, blogs, and the news
- Tokenize the cleaned words, and extract and count ngrams of size 1-5
- Generate a probability for each ngram consisting of:
$$Prob = count(Ngram)/count((N-1)gram)$$
where $count(Ngram)$ is the frequency of that full ngram in the corpus and $count((N-1)gram)$ is the frequency of the first $N-1$ words in the ngram.

Conclusion and Future Work
========================================================

- Once loaded, the app is fast through extensive use of data.table library
- In next steps, the user interface will collect user words from phrases and also as corrections when the prediction is not accurate
    - The new ngrams will be added to the existing data sets and provide new high-value data from the user
    - In this way, the app will customize itelf for the set of users that use it
