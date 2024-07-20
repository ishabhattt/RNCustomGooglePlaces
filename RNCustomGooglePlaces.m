#import "RNCustomGooglePlaces.h"
#import <React/RCTLog.h>
#import <GooglePlaces/GooglePlaces.h>

@interface RNCustomGooglePlaces() <GMSAutocompleteViewControllerDelegate>
@property (nonatomic, strong) RCTPromiseResolveBlock resolveBlock;
@property (nonatomic, strong) RCTPromiseRejectBlock rejectBlock;
@end

@implementation RNCustomGooglePlaces

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openAutocompleteModal:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  self.resolveBlock = resolve;
  self.rejectBlock = reject;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    GMSAutocompleteViewController *autocompleteController = [[GMSAutocompleteViewController alloc] init];
    autocompleteController.delegate = self;

    if (@available(iOS 13.0, *)) {
      UIUserInterfaceStyle userInterfaceStyle = UIScreen.mainScreen.traitCollection.userInterfaceStyle;
      if (userInterfaceStyle == UIUserInterfaceStyleDark) {
        autocompleteController.primaryTextColor = [UIColor whiteColor];
        autocompleteController.secondaryTextColor = [UIColor lightGrayColor];
        autocompleteController.tableCellBackgroundColor = [UIColor blackColor];
        autocompleteController.tableCellSeparatorColor = [UIColor grayColor];
      } else {
        autocompleteController.primaryTextColor = [UIColor blackColor];
        autocompleteController.secondaryTextColor = [UIColor darkGrayColor];
        autocompleteController.tableCellBackgroundColor = [UIColor whiteColor];
        autocompleteController.tableCellSeparatorColor = [UIColor lightGrayColor];
      }
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController presentViewController:autocompleteController animated:YES completion:nil];
  });
}

#pragma mark - GMSAutocompleteViewControllerDelegate

- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
  [viewController dismissViewControllerAnimated:YES completion:nil];
  
  NSMutableArray *addressComponents = [NSMutableArray array];
  for (GMSAddressComponent *component in place.addressComponents) {
    [addressComponents addObject:@{
      @"name": component.name,
      @"shortName": component.shortName,
      @"types": component.types
    }];
  }

  NSDictionary *viewport = @{
    @"latitudeNE": @(place.viewport.northEast.latitude),
    @"latitudeSW": @(place.viewport.southWest.latitude),
    @"longitudeNE": @(place.viewport.northEast.longitude),
    @"longitudeSW": @(place.viewport.southWest.longitude)
  };
  
  NSDictionary *placeInfo = @{
    @"address": place.formattedAddress ?: @"",
    @"addressComponents": addressComponents,
    @"location": @{
      @"latitude": @(place.coordinate.latitude),
      @"longitude": @(place.coordinate.longitude)
    },
    @"name": place.name ?: @"",
    @"placeID": place.placeID ?: @"",
    @"priceLevel": @(place.priceLevel),
    @"rating": @(place.rating),
    @"types": place.types,
    @"userRatingsTotal": @(place.userRatingsTotal),
    @"viewport": viewport
  };
  
  if (self.resolveBlock) {
    self.resolveBlock(placeInfo);
  }
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
  [viewController dismissViewControllerAnimated:YES completion:nil];
  
  if (self.rejectBlock) {
    self.rejectBlock(@"AUTOCOMPLETE_ERROR", error.localizedDescription, error);
  }
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
  [viewController dismissViewControllerAnimated:YES completion:nil];
  
  if (self.rejectBlock) {
    self.rejectBlock(@"USER_CANCELLED", @"User cancelled the operation", nil);
  }
}

@end
