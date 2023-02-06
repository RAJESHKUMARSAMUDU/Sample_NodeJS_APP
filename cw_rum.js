import { AwsRum } from 'aws-rum-web';

try {
  const config = {
    sessionSampleRate: 1,
    guestRoleArn: "arn:aws:iam::706205005497:role/RUM-Monitor-us-east-1-706205005497-0105434114761-Unauth",
    identityPoolId: "us-east-1:0a5be41c-9e97-4622-a30c-a520cfd34ea4",
    endpoint: "https://dataplane.rum.us-east-1.amazonaws.com",
    telemetries: ["performance","errors","http"],
    allowCookies: true,
    enableXRay: false
  };

  const APPLICATION_ID = '9826a7be-52b7-4b22-afa9-5108aecbb559';
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
