#output "pubilic_ip" {
#	value	=	"${aws_instance.web.public_ip}"
#}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}