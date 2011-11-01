/*
 Copyright 2011 Dmitry Stadnik. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are
 permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of
 conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list
 of conditions and the following disclaimer in the documentation and/or other materials
 provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY DMITRY STADNIK ``AS IS'' AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DMITRY STADNIK OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those of the
 authors and should not be interpreted as representing official policies, either expressed
 or implied, of Dmitry Stadnik.
 */

#import "GemiusClientImpl.h"

@implementation GemiusClientImpl

- (NSString *)encodeURIComponent:(NSString *)s {
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																(CFStringRef)s,
																NULL,
																(CFStringRef)@",/?:@&=+$#",
																kCFStringEncodingUTF8) autorelease];
}

- (NSString *)parametersWithPage:(NSString *)pageLink {
	NSMutableString *s = [NSMutableString string];
	[s appendString:@"&fr=1"];
	//[NSTimeZone resetSystemTimeZone];
	NSInteger minutes = [[NSTimeZone systemTimeZone] secondsFromGMT] / 60;
	[s appendFormat:@"&tz=%d", -minutes];
	[s appendString:@"&href="];
	[s appendString:[self encodeURIComponent:pageLink]];
	CGSize screen = [UIScreen mainScreen].bounds.size;
	[s appendString:@"&ref="];
	[s appendFormat:@"&screen=%dx%d&col=24", (NSInteger)screen.width, (NSInteger)screen.height];
	return s;
}

- (NSString *)extraParameters:(NSArray *)values {
	if (!values || [values count] == 0) {
		return @"";
	}
	return [@"&extra=" stringByAppendingString:[self encodeURIComponent:[values componentsJoinedByString:@"|"]]];
}

- (BOOL)trackPageView:(NSString *)pageLink error:(NSError **)error {
	//NSLog(@"Gemius: page view %@", pageLink);
	NSString *trackLink = [NSString stringWithFormat:@"%@/_%qi/rexdot.gif?l=30&id=%@%@%@",
						   self.beaconLink,
						   (long long)[[NSDate date] timeIntervalSince1970] * 1000,
						   self.siteID,
						   [self parametersWithPage:pageLink],
						   [self extraParameters:self.extraParameters]];
	//NSLog(@"Gemius: %@", trackLink);
	NSURL *trackURL = [NSURL URLWithString:trackLink];
	if (!trackURL) {
		return NO;
	}
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:trackURL
															cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
														timeoutInterval:30]
								  delegate:nil];
	return YES;
}

@end
