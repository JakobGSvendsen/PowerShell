// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Net.Http;
using System.IO;
using System.Management.Automation;

namespace Microsoft.PowerShell.Commands
{
    internal static class WebResponseObjectFactory
    {
        internal static WebResponseObject GetResponseObject(HttpResponseMessage response, Stream responseStream, ExecutionContext executionContext)
        {
            WebResponseObject output;
            if (WebResponseHelper.IsText(response))
            {
                output = new BasicHtmlWebResponseObject(response, responseStream);

            }
            else
            {
                output = new WebResponseObject(response, responseStream);
            }

            return (output);
        }
    }
}
