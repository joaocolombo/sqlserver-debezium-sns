using Google.Api.Gax;
using Google.Cloud.PubSub.V1;

var projectId = "meu-projeto-local";
var subscriptionId = "cdcserver.CadastroDB.dbo.pessoa.sub";

Environment.SetEnvironmentVariable(
    "PUBSUB_EMULATOR_HOST",
    "localhost:8085");

var builder = new SubscriberClientBuilder
{
    EmulatorDetection = EmulatorDetection.EmulatorOnly,
    SubscriptionName = SubscriptionName.FromProjectSubscription(
        projectId,
        subscriptionId)
};


var subscriber = await builder.BuildAsync();

await subscriber.StartAsync((message, ct) =>
{
    Console.WriteLine("============");
    Console.WriteLine(message.Data.ToStringUtf8());
    return Task.FromResult(SubscriberClient.Reply.Ack);
});