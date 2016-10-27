###AppmobiSecurity SDK for iOS




**Appmobi provides real time monitoring of in app activity using a set of predefined and customizable rules capable of identifying suspicious behavior that may lead to an application breach or data hack.**


Getting Started

Installation can be done by using either of the two ways mentioned below : 


1. Manual Install : Manually download the Appmobi framework and drag drop it in project folder.

2. Using Cocoapods


```
pod 'AppmobiSecurity'
```


*Appmobi also features OAuth integration and for this we support third party authentication service providers such as  Facebook and Google SignIn SDK. In order to install these SDK please refer to the provider documentation. However, in our example project we have integrated these SDK using cocoapods as below :*


- Add below pods in the "Podfile" :

```
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FacebookShare'
pod 'GoogleSignIn'
```
- Run : 

```
pod install
```
