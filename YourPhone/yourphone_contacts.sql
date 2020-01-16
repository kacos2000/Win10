-- contacts.db
select 

*

from Contact
left join  phonenumber on phonenumber.contact_id = Contact.contact_id
left join  Contactdate on Contactdate.contact_id = Contact.contact_id
left join  emailaddress on emailaddress.contact_id = Contact.contact_id
left join  postaladdress on postaladdress.contact_id = Contact.contact_id