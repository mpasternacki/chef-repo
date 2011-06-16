#!/bin/sh
set -e -x

# http://wiki.opscode.com/display/chef/Package+Installation+on+Debian+and+Ubuntu

export DEBIAN_FRONTEND=noninteractive

echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" \
    > /etc/apt/sources.list.d/opscode.list

apt-key add - <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.9 (GNU/Linux)

mQGiBEppC7QRBADfsOkZU6KZK+YmKw4wev5mjKJEkVGlus+NxW8wItX5sGa6kdUu
twAyj7Yr92rF+ICFEP3gGU6+lGo0Nve7KxkN/1W7/m3G4zuk+ccIKmjp8KS3qn99
dxy64vcji9jIllVa+XXOGIp0G8GEaj7mbkixL/bMeGfdMlv8Gf2XPpp9vwCgn/GC
JKacfnw7MpLKUHOYSlb//JsEAJqao3ViNfav83jJKEkD8cf59Y8xKia5OpZqTK5W
ShVnNWS3U5IVQk10ZDH97Qn/YrK387H4CyhLE9mxPXs/ul18ioiaars/q2MEKU2I
XKfV21eMLO9LYd6Ny/Kqj8o5WQK2J6+NAhSwvthZcIEphcFignIuobP+B5wNFQpe
DbKfA/0WvN2OwFeWRcmmd3Hz7nHTpcnSF+4QX6yHRF/5BgxkG6IqBIACQbzPn6Hm
sMtm/SVf11izmDqSsQptCrOZILfLX/mE+YOl+CwWSHhl+YsFts1WOuh1EhQD26aO
Z84HuHV5HFRWjDLw9LriltBVQcXbpfSrRP5bdr7Wh8vhqJTPjrQnT3BzY29kZSBQ
YWNrYWdlcyA8cGFja2FnZXNAb3BzY29kZS5jb20+iGAEExECACAFAkppC7QCGwMG
CwkIBwMCBBUCCAMEFgIDAQIeAQIXgAAKCRApQKupg++Caj8sAKCOXmdG36gWji/K
+o+XtBfvdMnFYQCfTCEWxRy2BnzLoBBFCjDSK6sJqCu5Ag0ESmkLtBAIAIO2SwlR
lU5i6gTOp42RHWW7/pmW78CwUqJnYqnXROrt3h9F9xrsGkH0Fh1FRtsnncgzIhvh
DLQnRHnkXm0ws0jV0PF74ttoUT6BLAUsFi2SPP1zYNJ9H9fhhK/pjijtAcQwdgxu
wwNJ5xCEscBZCjhSRXm0d30bK1o49Cow8ZIbHtnXVP41c9QWOzX/LaGZsKQZnaMx
EzDk8dyyctR2f03vRSVyTFGgdpUcpbr9eTFVgikCa6ODEBv+0BnCH6yGTXwBid9g
w0o1e/2DviKUWCC+AlAUOubLmOIGFBuI4UR+rux9affbHcLIOTiKQXv79lW3P7W8
AAfniSQKfPWXrrcAAwUH/2XBqD4Uxhbs25HDUUiM/m6Gnlj6EsStg8n0nMggLhuN
QmPfoNByMPUqvA7sULyfr6xCYzbzRNxABHSpf85FzGQ29RF4xsA4vOOU8RDIYQ9X
Q8NqqR6pydprRFqWe47hsAN7BoYuhWqTtOLSBmnAnzTR5pURoqcquWYiiEavZixJ
3ZRAq/HMGioJEtMFrvsZjGXuzef7f0ytfR1zYeLVWnL9Bd32CueBlI7dhYwkFe+V
Ep5jWOCj02C1wHcwt+uIRDJV6TdtbIiBYAdOMPk15+VBdweBXwMuYXr76+A7VeDL
zIhi7tKFo6WiwjKZq0dzctsJJjtIfr4K4vbiD9Ojg1iISQQYEQIACQUCSmkLtAIb
DAAKCRApQKupg++CauISAJ9CxYPOKhOxalBnVTLeNUkAHGg2gACeIsbobtaD4ZHG
0GLl8EkfA8uhluM=
=zKAm
-----END PGP PUBLIC KEY BLOCK-----
EOF

debconf-set-selections <<EOF
sun-java6-bin	shared/accepted-sun-dlj-v1-1	boolean	true
sun-java6-jdk	shared/accepted-sun-dlj-v1-1	boolean	true
sun-java6-jre	shared/accepted-sun-dlj-v1-1	boolean	true
sun-java6-jre	sun-java6-jre/stopthread	boolean	true
sun-java6-jre	sun-java6-jre/jcepolicy	note	
sun-java6-bin	shared/error-sun-dlj-v1-1	error	
sun-java6-jdk	shared/error-sun-dlj-v1-1	error	
sun-java6-jre	shared/error-sun-dlj-v1-1	error	
sun-java6-bin	shared/present-sun-dlj-v1-1	note	
sun-java6-jdk	shared/present-sun-dlj-v1-1	note	
sun-java6-jre	shared/present-sun-dlj-v1-1	note	
chef-solr	chef-solr/amqp_password	password	`openssl rand -hex 16`
chef	chef/chef_server_url	string	http://localhost:4000/
EOF

apt-get update
apt-get upgrade --yes
apt-get install --yes \
    sun-java6-jre libmerb-haml-ruby \
    chef chef-server-api

/etc/init.d/chef-solr start

apt-get install --yes chef-expander

chef-client
