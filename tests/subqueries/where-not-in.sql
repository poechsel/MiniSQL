SELECT * FROM "employes.csv" AS employes
WHERE employes.dpt NOT IN (
	SELECT depts.idd FROM "departements.csv" depts
	WHERE depts.idd > 2
);

[normal]
ide,nom,email,dpt
1,"Hamish Fulton",diam.eu.dolor@vel.net,1
7,"Gemma Calhoun",Mauris.vestibulum.neque@inhendreritconsectetuer.com,1
8,"Devin Bolton",est.arcu@Vestibulum.com,1
9,"McKenzie Jensen",velit.justo@Suspendisseseddolor.co.uk,1
14,"Kieran Weaver",ac.eleifend.vitae@ornarelectus.net,1
17,"Tatyana Becker",in.cursus.et@mauris.com,10
18,"Kenyon Hood",In.lorem@urna.org,2
21,"Hoyt Alston",pretium.neque@nunc.com,10
22,"Oliver Lowe",imperdiet.erat.nonummy@pharetra.ca,2
25,"Ray Tran",Vestibulum.ante.ipsum@interdumligulaeu.com,10
29,"Tana Thomas",adipiscing.elit@semut.com,1
45,"Iona Rasmussen",vitae.purus.gravida@enimSuspendisse.com,20
46,"Aidan Livingston",commodo.tincidunt@eu.co.uk,20
48,"Vivian Gregory",id.magna@utquamvel.com,1
50,"Odysseus Joyce",ornare@In.edu,20
52,"Melinda Lott",purus.sapien.gravida@quis.com,10
54,"Eliana Santos",a.mi.fringilla@ipsumSuspendissenon.edu,1
55,"Diana Peterson",a@orciinconsequat.edu,2
57,"Vernon Nieves",risus.quis@Cumsociis.ca,2
65,"Austin Mueller",eros.non@consectetuermaurisid.com,1
66,"Forrest Harrison",erat@ametmetusAliquam.com,2
70,"Alexander Sullivan",urna@Nullaegetmetus.edu,10
73,"Fredericka Alexander",metus.vitae.velit@iaculislacuspede.com,1
75,"Blaze Cooper",Cras@tempus.com,20
76,"Clark Henson",eros.non@necimperdietnec.co.uk,1
78,"Kameko Short",rutrum.urna.nec@eu.co.uk,1
83,"Iris Mcbride",per@Integertinciduntaliquam.ca,1
91,"Thor Bush",mauris@commodoauctorvelit.net,1
92,"Ora Grimes",dolor.Donec.fringilla@vitae.com,2
97,"Carl Marquez",dui.Fusce@dis.co.uk,20
98,"Lillian Berg",semper.Nam@facilisis.org,2
99,"Evan Lynch",venenatis.lacus.Etiam@ascelerisque.com,20

