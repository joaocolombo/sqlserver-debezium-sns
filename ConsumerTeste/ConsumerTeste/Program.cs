
using Amazon;
using Amazon.Runtime;
using Amazon.SQS;
using Amazon.SQS.Model;

var credentials = new BasicAWSCredentials("test", "test");

var sqs = new AmazonSQSClient(
    credentials,
    new AmazonSQSConfig
    {
        ServiceURL = "http://localhost:4566",
        AuthenticationRegion = "us-east-1"
    });


string queueUrl = "http://localhost:4566/000000000000/fila-dados-pessoa";

Console.WriteLine("Consumindo mensagens...");

while (true)
{
    var response = await sqs.ReceiveMessageAsync(new ReceiveMessageRequest
    {
        QueueUrl = queueUrl,
        MaxNumberOfMessages = 10,
        WaitTimeSeconds = 20,
        VisibilityTimeout = 30
    });

    foreach (var message in response.Messages)
    {
        Console.WriteLine("--------------------------------");
        Console.WriteLine(message.Body);
        Console.WriteLine("--------------------------------");

        // Remove a mensagem da fila
        await sqs.DeleteMessageAsync(queueUrl, message.ReceiptHandle);
    }
}