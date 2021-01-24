# trendmicro\_server\_updates

## Finality
It's an exemple of automated script which download all Virus signature files from Trend Micro' servers (zip and sig files).
It's dedicaced to OfficeScan/Apex One servers and nothing else, and works on Windows only.
It's usefull for offline antivirus server.

If a proxy is set (w/o login password) in the internet settings, th script takes it into account.
Credentials can be added, with for exemple the commented function "Get-Credentials".


## Usage
The script accept an optional parameter : -output_dir
By default, the script downloads files on a created subdirectory "updates" from the script path.


## Note
After have downloaded files (about 1.7Gio), you can create another IIS web site, corresponding to the download path.
Therefore, it will be easier, from the ApexOne Web GUI, to point the update to this new web site. 
You also can point to an UNC path, like a samba server.


## To do
Clean old file versions
