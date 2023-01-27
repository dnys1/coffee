import {
  App,
  CfnOutput,
  Duration,
  RemovalPolicy,
  Stack,
  StackProps,
} from "aws-cdk-lib";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as cloudfront from "aws-cdk-lib/aws-cloudfront";
import * as origins from "aws-cdk-lib/aws-cloudfront-origins";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as lambda_nodejs from "aws-cdk-lib/aws-lambda-nodejs";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as targets from "aws-cdk-lib/aws-route53-targets";
import * as s3 from "aws-cdk-lib/aws-s3";
import { Construct } from "constructs";

export class CoffeeStack extends Stack {
  constructor(scope: Construct, id: string, props: StackProps = {}) {
    super(scope, id, props);

    // Create the Lambda to proxy to the coffee API. Output a URL which can be
    // invoked by the frontend.
    const proxy = new lambda_nodejs.NodejsFunction(this, "proxy", {
      runtime: lambda.Runtime.NODEJS_18_X,
      // Give some extra time since base64 encoding the response body can be slow.
      timeout: Duration.seconds(10),
    });
    const proxyUrl = proxy.addFunctionUrl({
      authType: lambda.FunctionUrlAuthType.NONE,
      cors: {
        allowedOrigins: ["*"],
        maxAge: Duration.hours(1),
      },
    });

    new CfnOutput(this, "ProxyUrl", {
      value: proxyUrl.url,
    });

    const baseDomain = "dillonnys.com";
    const hostedZone = route53.HostedZone.fromLookup(this, "HostedZone", {
      domainName: baseDomain,
    });
    const coffeeDomain = `coffee.${baseDomain}`;

    const { certificate } = new CertificateStack(this, "Certificate", {
      domainName: coffeeDomain,
      hostedZone,
      env: { region: "us-east-1", account: this.account },
    });

    // Build the Flutter Web app with the proxy URL injected.
    const bucket = new s3.Bucket(this, "Bucket", {
      bucketName: coffeeDomain,
      enforceSSL: true,
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
      accessControl: s3.BucketAccessControl.PRIVATE,
      publicReadAccess: false,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      encryption: s3.BucketEncryption.S3_MANAGED,
    });

    const originAccessId = new cloudfront.OriginAccessIdentity(
      this,
      "OriginAccessIdentity",
      {
        comment: "Access to the bucket",
      }
    );

    bucket.grantRead(originAccessId);

    const distribution = new cloudfront.Distribution(this, "Distribution", {
      defaultBehavior: {
        origin: new origins.S3Origin(bucket, {
          originAccessIdentity: originAccessId,
        }),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      },
      domainNames: [coffeeDomain],
      certificate,
      defaultRootObject: "index.html",
      errorResponses: [
        {
          httpStatus: 403,
          responseHttpStatus: 200,
          responsePagePath: "/index.html",
        },
        {
          httpStatus: 404,
          responseHttpStatus: 200,
          responsePagePath: "/index.html",
        },
      ],
      priceClass: cloudfront.PriceClass.PRICE_CLASS_ALL,
      minimumProtocolVersion: cloudfront.SecurityPolicyProtocol.TLS_V1_2_2019,
      enableIpv6: true,
    });

    new CfnOutput(this, "DistributionId", {
      value: distribution.distributionId,
    });

    const aliasTarget = route53.RecordTarget.fromAlias(
      new targets.CloudFrontTarget(distribution)
    );

    new route53.ARecord(this, "AliasRecord", {
      zone: hostedZone,
      recordName: coffeeDomain,
      target: aliasTarget,
    });

    new route53.AaaaRecord(this, "AaaaRecord", {
      zone: hostedZone,
      recordName: coffeeDomain,
      target: aliasTarget,
    });

    new route53.CnameRecord(this, "CnameRecord", {
      zone: hostedZone,
      recordName: `www.${coffeeDomain}`,
      domainName: coffeeDomain,
    });
  }
}

interface CertificateStackProps extends StackProps {
  domainName: string;
  hostedZone: route53.IHostedZone;
}

class CertificateStack extends Stack {
  constructor(scope: Construct, id: string, props: CertificateStackProps) {
    super(scope, id, props);

    const { domainName, hostedZone } = props;

    this.certificate = new acm.Certificate(this, "Certificate", {
      domainName,
      validation: acm.CertificateValidation.fromDns(hostedZone),
    });
  }

  certificate: acm.Certificate;
}

const app = new App();

new CoffeeStack(app, "Coffee", {
  crossRegionReferences: true,
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
});

app.synth();
