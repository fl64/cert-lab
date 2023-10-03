verify:
	openssl verify -show_chain -CAfile tmp/ca.pem tmp/tls.pem

client:
	openssl x509 -text -noout -in tmp/tls.pem

build:
	go build -o main main.go

test-ip:
	./main "1.1.1.1" tmp/tls.pem tmp/ca.pem

test-name:
	./main "xxx" tmp/tls.pem tmp/ca.pem

clean:
	rm -rf tmp
