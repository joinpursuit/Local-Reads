# Local Reads

# By TMT

## Introduction

Developed over a 2 day hackathon, LocalReads is a simple social network based around local libraries in Queens NYC allowing users to see what other members of their community are reading and allows them to share books they have read with ratings and comments. 
 
We aim to generate interest in local libraries, while allowing users to keep a log of the books they have read.

## Minimum Requirements 

* Xcode 8
* iOS 10.0

## Instalation

* Fork/Clone the repo: https://github.com/C4Q/Local-Reads
* Run pod install and open LocalReads.xcworkspace


## Flow


### Login

<img width="313" alt="screen shot 2017-04-19 at 10 13 00" src="https://cloud.githubusercontent.com/assets/20875592/25185545/a119f13c-24eb-11e7-90c3-a073d885aa78.png">

Users login or register. 
User Authentication and storage is done through Firebase.

### Main Feed

<img width="308" alt="screen shot 2017-04-19 at 10 42 57" src="https://cloud.githubusercontent.com/assets/20875592/25186089/173ee506-24ed-11e7-93c5-54f2d1c6478d.png">

* The main feed is a table view that shows posts made by all users from all libraries in Queens. 
* The feed can be filtered by library by tapping on the filter icon in top right corner and selecting the library.
* Library information is sourced from NYC Open Data's API.
* Tapping on a cell will bring you to that users profile page where you can see the history off all the posts they have made.

### Adding a Post

<img width="312" alt="screen shot 2017-04-19 at 11 06 23" src="https://cloud.githubusercontent.com/assets/20875592/25187187/42e2acda-24f0-11e7-91d8-22bb81eea729.png">

* Users can find the book they want to rate and comment on by searching in the search bar at the top.
* We use Google Books API to get the book information and images and display the results in a collection view for the user to select.
* The user can then select how many stars out of 5 they rate the book. The star rating interface is a 3rd party library called Cosmos. https://cocoapods.org/pods/Cosmos
* After writing a comment, the user taps the checkmark button and the post info is uploaded to their history on firebase.




