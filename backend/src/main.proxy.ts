import * as lambda from "aws-lambda";
import type { RequestInfo, RequestInit, Response } from "node-fetch";

const BASE_URL = "https://coffee.alexflipnote.dev";

// For some reason, the `fetch` global is not in the Node types package,
// even though it's included in Node >=18.
// https://github.com/DefinitelyTyped/DefinitelyTyped/issues/60924
declare function fetch(url: RequestInfo, init?: RequestInit): Promise<Response>;

/// Invokes the coffee API and returns the response.
export const handler: lambda.APIGatewayProxyHandlerV2 = async (event) => {
  const { rawPath } = event;
  const url = new URL(rawPath, BASE_URL);
  try {
    const resp = await fetch(url);
    // Base64 encode the response body so that it can be returned as a string.
    const body = await resp.arrayBuffer();
    const bodyBase64 = Buffer.from(body).toString("base64");
    return {
      statusCode: resp.status,
      body: bodyBase64,
      isBase64Encoded: true,
    };
  } catch (error) {
    console.error(`Error fetching ${url}: ${error}`);
    return {
      statusCode: 500,
      body: "Internal Server Error",
    };
  }
};
