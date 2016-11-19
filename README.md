# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Jiwen You
+ Projec title: Words 4 Music
+ Project summary: The project is to predict the lyrics given the melody of the song. I am provided with 2350 song with both lyric occurrence matrix and musical features, such as bars and beats. The following is the general idea for my project

1. Keep all fifteen features, except for “song” and choose appropriate lengths for each features according to the histogram.
2. Reset the length for all songs and combine all fifteen features of the song into a vector individually.
3. Apply PCA to the new data and retain all principle components
4. Classify the songs into ten topics and calculate the distribution of words within each topic using topic modeling
5. Given principle components and predicted topics, train the modeling using random forest
6. Apply similar procedure to the test dataset and do the prediction

	
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
