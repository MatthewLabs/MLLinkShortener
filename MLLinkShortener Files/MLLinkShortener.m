//
//  MLLinkShortener.m
//  MLLinkShortener
//
//  Created by Matteo Del Vecchio on 30/06/13.
//  Copyright (c) 2012 Matthew Labs. All rights reserved.
//

#import "MLLinkShortener.h"


@implementation NSString (MLLinkEncoding)
-(NSString *)encodeLink
{
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self,
																				 NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																				 kCFStringEncodingUTF8);
}
@end


@interface MLLinkShortener ()
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSString *linkToShorten;
@property (nonatomic, assign) MLLinkShortenerOption URLShortener;

@property (strong, nonatomic) MLLinkShortenerSuccessBlock successBlock;
@property (strong, nonatomic) MLLinkShortenerFailureBlock failureBlock;
@end

@implementation MLLinkShortener

-(id)initWithLink:(NSString *)link usingShortener:(MLLinkShortenerOption)shortener
{
	self = [super init];
	if (self)
	{
		_linkToShorten = link;
		_URLShortener = shortener;
	}
	
	return self;
}

+(MLLinkShortener *)prepareLink:(NSString *)link usingShortner:(MLLinkShortenerOption)shortener
{
	return [[self alloc] initWithLink:link usingShortener:shortener];
}

-(void)shortLinkWithOptions:(NSDictionary *)options success:(MLLinkShortenerSuccessBlock)successBlock failure:(MLLinkShortenerFailureBlock)failureBlock
{
	self.successBlock = successBlock;
	self.failureBlock = failureBlock;
	
	if (!self.failureBlock)
		[[NSException exceptionWithName:@"MLLinkShortenerException" reason:@"failureBlock IS nil" userInfo:@{@"error": @"An istance of MLLinkShortener CAN'T have a nil failureBlock."}] raise];
	
	if (!self.linkToShorten || [self.linkToShorten length] == 0)
	{
		NSError *error = [NSError errorWithDomain:@"MLLinKShortenerError" code:101 userInfo:@{@"error": @"An istance of MLLinkShortener CAN'T shorten a link if it has not been provided. Check if it is nil."}];
		self.failureBlock(error);
		return;
	}
	
	if (!self.successBlock)
	{
		NSError *error = [NSError errorWithDomain:@"MLLinkShortenerError" code:102 userInfo:@{@"error": @"An istance of MLLinkShortener CAN'T have a nil successBlock."}];
		self.failureBlock(error);
		return;
	}
	
	NSString *encodedLink = nil;
	NSMutableURLRequest *request = nil;
	
	if ([self.linkToShorten hasPrefix:@"http://"] || [self.linkToShorten hasPrefix:@"https://"])
		encodedLink = [self.linkToShorten encodeLink];
	else
		encodedLink = [[NSString stringWithFormat:@"http://%@", self.linkToShorten] encodeLink];
	
	switch (self.URLShortener)
	{
		case MLLinkShortenerBitly:
		{
			if (!options || ![options valueForKey:@"username"] || ![options valueForKey:@"apiKey"])
			{
				NSError *error = [NSError errorWithDomain:@"MLLinkShortenerCredentialsError" code:401 userInfo:@{@"error": @"To use Bit.ly URL Shortener, an api key and an username are required. Provide them using the options dictionary with \"apiKey\" and \"username\" keys."}];
				self.failureBlock(error);
				return;
			}
			
			NSString *username = [options valueForKey:@"username"];
			NSString *apiKey = [options valueForKey:@"apiKey"];
			
			request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json", username, apiKey, encodedLink]]];
				
			break;
		}
		case MLLinkShortenerGoogl:
		{
			if (![options valueForKey:@"apiKey"] || !options)
			{
				NSError *error = [NSError errorWithDomain:@"MLLinkShortenerCredentialsError" code:401 userInfo:@{@"error": @"To use Goo.gl URL Shortener, an api key is required. Provide it using the options dictionary with \"apiKey\" key."}];
				self.failureBlock(error);
				return;
			}
				
			NSString *apiKey = [options valueForKey:@"apiKey"];
			
			request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/urlshortener/v1/url?key=%@", apiKey]]];
			
			NSString *jsonRequest = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", encodedLink];
			[request setHTTPBody:[NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]]];
			[request setHTTPMethod:@"POST"];
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			
			break;
		}
		case MLLinkShortenerIsGd:
		{
			request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://is.gd/create.php?format=json&url=%@", encodedLink]]];
			[request setHTTPMethod:@"POST"];
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			
			break;
		}
		case MLLinkShortenerLinkyy:
		{
			request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://linkyy.com/create_api?url=%@", encodedLink]]];
			break;
		}
		case MLLinkShortenerVGd:
		{
			request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://v.gd/create.php?format=json&url=%@", encodedLink]]];
			[request setHTTPMethod:@"POST"];
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			break;
		}
	}
	
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (con)
	{
		self.receivedData = [NSMutableData data];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	else
	{
		NSError *error = [NSError errorWithDomain:@"MLLinkShortenerConnectionError" code:201 userInfo:@{@"error": @"An unknown error occurred while starting connection. Check your network."}];
		self.failureBlock(error);
	}
}

#pragma mark - NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.receivedData = nil;
	self.failureBlock(error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	switch (self.URLShortener)
	{
		case MLLinkShortenerBitly:
		{
			NSError *error = nil;
			NSArray *result = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingAllowFragments error:&error];
			if (error)
				self.failureBlock(error);
			else
			{
				if ([[result valueForKey:@"data"] valueForKey:@"url"])
				{
					NSString *urlString = [[result valueForKey:@"data"] valueForKey:@"url"];
					NSURL *url = [NSURL URLWithString:urlString];
					self.successBlock(url);
				}
				else
				{
					NSLog(@"%@", result);
					NSError *error = [NSError errorWithDomain:@"MLLinkShortenerError" code:301 userInfo:@{@"error": @"Unable to parse shortened link."}];
					self.failureBlock(error);
				}
			}
			break;
		}
		case MLLinkShortenerGoogl:
		{
			NSError *error = nil;
			NSArray *result = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingAllowFragments error:&error];
			if (error)
				self.failureBlock(error);
			else
			{
				if ([result valueForKey:@"id"])
				{
					NSString *urlString = [result valueForKey:@"id"];
					NSURL *url = [NSURL URLWithString:urlString];
					self.successBlock(url);
				}
				else
				{
					NSLog(@"%@", result);
					NSError *error = [NSError errorWithDomain:@"MLLinkShortenerError" code:301 userInfo:@{@"error": @"Unable to parse shortened link."}];
					self.failureBlock(error);
				}
			}
			break;
		}
		case MLLinkShortenerIsGd:
		case MLLinkShortenerVGd:
		{
			NSError *error = nil;
			NSArray *result = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingAllowFragments error:&error];
			if (error)
				self.failureBlock(error);
			else
			{
				if ([result valueForKey:@"shorturl"])
				{
					NSString *urlString = [result valueForKey:@"shorturl"];
					NSURL *url = [NSURL URLWithString:urlString];
					self.successBlock(url);
				}
				else
				{
					NSLog(@"%@", result);
					NSError *error = [NSError errorWithDomain:@"MLLinkShortenerError" code:301 userInfo:@{@"error": @"Unable to parse shortened link."}];
					self.failureBlock(error);
				}
			}
			break;
		}
		case MLLinkShortenerLinkyy:
		{
			NSString *result = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
			
			if ([result isEqualToString:@"Error"] || [result isEqualToString:@"ERROR"])
			{
				NSLog(@"%@", result);
				NSError *error = [NSError errorWithDomain:@"MLLinkShortenerError" code:301 userInfo:@{@"error": @"Unable to parse shortened link."}];
				self.failureBlock(error);
			}
			else
			{
				NSURL *url = [NSURL URLWithString:result];
				self.successBlock(url);
			}
			break;
		}
	}
	
	self.receivedData = nil;
}


@end
