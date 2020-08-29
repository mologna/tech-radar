import { Stack, StackProps, App } from '@aws-cdk/core';
import { Bucket, BlockPublicAccess } from '@aws-cdk/aws-s3';
import { OriginAccessIdentity, CloudFrontWebDistribution } from '@aws-cdk/aws-cloudfront';

export class StaticWebsiteStack extends Stack {
    constructor(scope: App, id: string, props?: StackProps) {
        super(scope, id, props);
        const oai = new OriginAccessIdentity(this, `CloudFrontOriginAccessIdentity`);
        const bucket = new Bucket(this, 'S3Bucket', {
            blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
        });
        bucket.grantRead(oai);
        new CloudFrontWebDistribution(this, 'CloudFrontDistribution', {
            originConfigs: [
                {
                    s3OriginSource: {
                        s3BucketSource: bucket,
                        originAccessIdentity: oai
                    },
                    behaviors: [
                        { isDefaultBehavior: true }
                    ]
                },
            ],
        });
    }
}

const app = new App();
new StaticWebsiteStack(app, 'tech-radar', {
    tags: {
        BUSINESS_UNIT: 'PSS',
        BUSINESS_REGION: 'NORTHAMERICA',
        PLATFORM: 'SONASH-ONGOING_VALUE',
        CLIENT: 'NONE',
    }
});