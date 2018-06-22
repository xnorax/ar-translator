<!-- [![Build Status](https://travis-ci.org/IBM/watson-banking-chatbot.svg?branch=master)](https://travis-ci.org/IBM/watson-banking-chatbot)

*Read this in other languages: [العربية](README-ar.md).* -->

# Create a Mobile App for Augmented Reality Translation

<table>
  <tr>
    <th>
      <img src="./screenshots/1.PNG" width="220"/>
    </th>
    <th>
      <img src="./screenshots/2.PNG" width="220"/>
    </th>
    <th>
    <img src="./screenshots/3.jpeg" width="220"/>
    </th>
  </tr>
</table>

In this developer journey, we will create an iOS mobile app using Swift, Watson Visual Recognition and Watson Language Translator. The Visual Recognition service will be used to identify text of a captured images. That text can then be translated to any of the supported languages by Watson Language Translator.

When the reader has completed this journey, they will understand how to:

* Create a mobile app that translates text in a photo using Watson Visual Recognition
* Use Watson Language Translator to translated written text

<!-- [comment]: <> (architicture image) -->

## Flow
1. The user takes a photo via the mobile app and move automatically to the second user interface.
2. User image is processed with Visual Recognition to detect English text in the captured image.
3. Optionally, user can edit or add to the identified text labels.
4. User chooses a language to translate the English text into.

## With Watson

Want to take your Watson app to the next level? Looking to leverage Watson Brand assets? Join the [With Watson](https://www.ibm.com/watson/with-watson) program which provides exclusive brand, marketing, and tech resources to amplify and accelerate your Watson embedded commercial solution.

## Included components

* [IBM Watson Visual Recognition](https://www.ibm.com/watson/developercloud/visual-recognition): Quickly and accurately tag, classify and train visual content using machine learning.
* [IBM Watson Language Translator](https://www.ibm.com/watson/developercloud/language-translatorl): Translate text from one language to another. The service offers multiple IBM provided translation models that you can customize based on your unique terminology and language.
* [Eureka](https://github.com/xmartlabs/Eureka): Eureka is a form builder framework for iOS applications.

# Technologies

* [Artificial Intelligence](https://medium.com/ibm-data-science-experience): Artificial intelligence can be applied to disparate solution spaces to deliver disruptive technologies.
* [Mobile](https://mobilefirstplatform.ibmcloud.com/): Systems of engagement are increasingly using mobile technology as the platform for delivery.

# Watch the Video

<!-- [![](http://img.youtube.com/vi/Jxi7U7VOMYg/0.jpg)](https://www.youtube.com/watch?v=Jxi7U7VOMYg) -->

# Steps


### Step 1. Clone the repository

- At a command line, clone this repo:
```
git clone [repo link]
```
### Step 2. Create required services

- Log into your IBM Cloud account. [Sign up](http://bluemix.net/) if you do not already have one.

- From the IBM Cloud catalog, create a [Watson Visual Recognition](https://console.bluemix.net/catalog/services/visual-recognition) service. Create a set of credentials and identify your API key.

- From the IBM Cloud catalog, create a [Watson Language Translator](https://console.bluemix.net/catalog/services/language-translator) service. Create a set of credentials and copy your username and password.

### Step 3. Configure service credintials

- When you run the app on Xcode, go to `Credintials.swift` and paste your own credentials from the previous step. 

### Step 4. Download the required frameworks

- Using [Carthage](), run the following command to create a Carthage file
```
touch Cartfile
```

- Specify the frameworks in your carthage file
```
github "watson-developer-cloud/swift-sdk"
github "xmartlabs/Eureka" ~> 4.0
```

- Then run the following command to build the dependencies and frameworks:
```
carthage update --platform iOS
```
You should then see the downloaded frameworks in `Carthage/Build/iOS` folder

- On Xcode, select your application target and then the "General" tab. Now drag `VisualRecognitionV3.framework`, `LanguageTranslatorV2.framework` and `Eureka.framework`  to the **Embedded Binaries** section and you're done :]