# HIEofOne-Connect
IOS app to connect Apple Clinical Records to NOSH

# Install
- download code and open the file ending in .xcodeproj in xcode (mac required does not run on windows)
- make sure your signing certificates are correct

# Features
- connects with apple health
- lists all users records in app
- extracts json FHIR data for each resource
  - Click on a record to see it's json object
- qr code scanner (not finished)

# TODO
- Connect to NOSH
  - This requires a qr code scan. You can find a view controller which can read qr codes included in the project.
  - Once the qr code is scanned some sort of JWT token must be provided for the next step... (talk to micheal chen)
- Send resources to nosh (see NOSHconnect.swift for more instructions)
