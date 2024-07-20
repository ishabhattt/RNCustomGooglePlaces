# RNCustomGooglePlaces
Theming fix in RNGooglePlaces modal in IPhone 13+

A detailed description given on how to create custom objective file and attach it to fix the theming in React Native
and get a whole data object as you get from RNGooglePlaces in return like name, address, latitude, longitude etc

1) First create RNCustomGooglePlaces.m file an Objective-C file**
2) Create RNCustomGooglePlaces.h a header file
3) Then a bridging header file with the name of your project and current target and attach it in build settings
4)  Import it as NativeModules from react-native
5)  Use it like const {RNCustomGooglePlaces} = NativeModules;

Have a Great Day!!!!!!

