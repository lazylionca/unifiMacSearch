# unifiMacSearch
Use ssh to search to the unifi mongo db for a mac address

The unoffical unifi API doesn't have a simple way to search by mac address.
Here's a bash script to do it for you.

Download to anywhere you can run bash from and reach the cli of your unifi server.
If you are using Windows, I recommend checking out mobaxterm.

Modify the server and username (lines 18 & 19) appropriately.

  sh checkUnifi.sh aa:bb:cc:dd:ee:ff 

It'll ask for your password, connect to your unifi server, and use mongodb commands to search for the mac and the site information.


FAQ: 

Why not use the API?

The Unifi API is not officially supported by Ubiquiti. ( https://ubntwiki.com/products/software/unifi-controller/api )
In my opinion, it is much more likely that the front-end devs will change something in a future update that affects the "api", 
than it is for the back-end database structure to be changed.

That said, I make no guarantees.
