/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "../AmazonSDKUtil.h"
#import "../AmazonAuthUtils.h"
#import "../AmazonClientException.h"
#import "../AmazonLogger.h"
#import "../AmazonServiceException.h"
#import "../AmazonSignatureException.h"
#import "../AmazonUnmarshallerXMLParserDelegate.h"
#import "../AmazonServiceRequest.h"
#import "../AmazonServiceRequestConfig.h"
#import "DynamoDBResponse.h"
#import "../AmazonServiceResponseUnmarshaller.h"
#import "../AmazonURLRequest.h"
#import "../AmazonCredentials.h"
#import "../AmazonRequestDelegate.h"
#import "../AmazonAbstractWebServiceClient.h"

@interface DynamoDBWebServiceClient:AmazonAbstractWebServiceClient
{
}

/** Utility method that sends the AmazonServiceRequest to be processed.
 *
 * @param request An AmazonServiceRequest describing the parameters of a request.
 * @return The response from the service.
 */
-(AmazonServiceResponse *)invoke:(AmazonServiceRequest *)generatedRequest rawRequest:(AmazonServiceRequestConfig *)originalRequest unmarshallerDelegate:(Class)unmarshallerDelegate;

@end

