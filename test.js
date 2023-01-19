//import { AwsRum, AwsRumConfig } from 'aws-rum-web';

const AwsRum = require('aws-rum-web');
const AwsRumConfig = require('aws-rum-web');
try {
  const config: AwsRumConfig = {
    sessionSampleRate: 1,
    guestRoleArn: "arn:aws:iam::706205005497:role/RUM-Monitor-us-east-1-706205005497-0105434114761-Unauth",
    identityPoolId: "us-east-1:0a5be41c-9e97-4622-a30c-a520cfd34ea4",
    endpoint: "https://dataplane.rum.us-east-1.amazonaws.com",
    telemetries: ["performance","errors","http"],
    allowCookies: true,
    enableXRay: false
  };

  const APPLICATION_ID: string = '9826a7be-52b7-4b22-afa9-5108aecbb559';
  const APPLICATION_VERSION: string = '1.0.0';
  const APPLICATION_REGION: string = 'us-east-1';

  const awsRum: AwsRum = new AwsRum(
    APPLICATION_ID,
    APPLICATION_VERSION,
    APPLICATION_REGION,
    config
  );
} catch (error) {
  // Ignore errors thrown during CloudWatch RUM web client initialization
}

var express = require('express');
var app = express();

// Jade
app.set('views', __dirname+'/views');
app.set('view engine', 'jade');

app.get('/', function(req, res){
                res.render('home', {
                        title: "Welcome to APP Home page",
                        date: new Date()
                });
});
