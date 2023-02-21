import { AwsRum } from 'aws-rum-web';

try {
  const config = {
    sessionSampleRate: 1,
    guestRoleArn: "arn:aws:iam::706205005497:role/RUM-Monitor-us-east-1-706205005497-3395422796761-Unauth",
    identityPoolId: "us-east-1:29830fc5-96fb-4107-82eb-f8d297783e79",
    endpoint: "https://dataplane.rum.us-east-1.amazonaws.com",
    telemetries: ["performance","errors","http"],
    allowCookies: true,
    enableXRay: false
  };

  const APPLICATION_ID = '4d9aed37-6edd-47b6-8f9a-81c9d5eb173d';
  const APPLICATION_VERSION = '1.0.0';
  const APPLICATION_REGION = 'us-east-1';

  const awsRum = new AwsRum(
    APPLICATION_ID,
    APPLICATION_VERSION,
    APPLICATION_REGION,
    config
  );
} catch (error) {
  // Ignore errors thrown during CloudWatch RUM web client initialization
}
