//
//  ViewController.m
//  BlinkOCR-sample
//
//  Created by Jura on 02/03/15.
//  Copyright (c) 2015 MicroBlink. All rights reserved.
//

#import "ViewController.h"

#import "PPFormOcrOverlayViewController.h"
#import <BlinkOCR/BlinkOCR.h>

@interface ViewController () <PPFormOcrOverlayViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)didTapScan:(id)sender {
    // Check if blink ocr is supported
    NSError *error;
    if ([PPCoordinator isPhotoPayUnsupported:&error]) {
        NSString *messageString = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:messageString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }

    PPScanElement *priceElement = [[PPScanElement alloc] initWithIdentifier:@"Amount" parserFactory:[[PPPriceOcrParserFactory alloc] init]];
    priceElement.localizedTitle = @"Iznos";
    priceElement.localizedTooltip = @"Skenirajte iznos za plaćanje";

    PPScanElement *ibanElement = [[PPScanElement alloc] initWithIdentifier:@"IBAN" parserFactory:[[PPIbanOcrParserFactory alloc] init]];
    ibanElement.localizedTitle = @"IBAN";
    ibanElement.localizedTooltip = @"Skenirajte IBAN";

    PPScanElement *referenceElement = [[PPScanElement alloc] initWithIdentifier:@"Reference" parserFactory:[[PPCroReferenceOcrParserFactory alloc] init]];
    referenceElement.localizedTitle = @"Poziv na broj";
    referenceElement.localizedTooltip = @"Skenirajte poziv na broj";

    PPSettings* settings = [[PPSettings alloc] init];
    settings.licenseSettings.licenseKey = @"NHF2-TG3T-OS5T-FVRY-CN6R-OTIA-FMRP-TOZL";

    // Allocate the recognition coordinator object
    PPCoordinator *coordinator = [[PPCoordinator alloc] initWithSettings:settings];

    PPFormOcrOverlayViewController *overlayViewController = [PPFormOcrOverlayViewController allocFromNibName:@"PPFormOcrOverlayViewController"];
    overlayViewController.scanElements = @[priceElement, ibanElement, referenceElement];
    overlayViewController.coordinator = coordinator;
    overlayViewController.delegate = self;

    UIViewController<PPScanningViewController>* scanningViewController = [coordinator cameraViewControllerWithDelegate:nil
                                                                                                 overlayViewController:overlayViewController];

    [self presentViewController:scanningViewController animated:YES completion:nil];
}

#pragma mark - PPFormOcrOverlayViewControllerDelegate

- (void)formOcrOverlayViewControllerWillClose:(PPFormOcrOverlayViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)formOcrOverlayViewController:(PPFormOcrOverlayViewController *)vc
       didFinishScanningWithElements:(NSArray *)scanElements {

    // HERE you perform business logic with scanned elements.
    // for example, this code displays the results in UILabel

    NSString* res = @"";

    for (PPScanElement* element in scanElements) {
        if (element.scanned) {
            res = [res stringByAppendingFormat:@"Scanned %@: %@\n", element.identifier, element.value];
        } else if (element.edited) {
            res = [res stringByAppendingFormat:@"Edited %@: %@\n", element.identifier, element.value];
        } else {
            res = [res stringByAppendingFormat:@"Empty %@\n", element.identifier];
        }
    }

    self.labelResult.text = res;

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
