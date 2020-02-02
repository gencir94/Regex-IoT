
%{

    #include <stdlib.h>
    #include <string.h>
    #define YY_DECL extern "C" int yylex()

    int lunghezza_coap=0;
    int lunghezza_mqtt=0;
    int lunghezza_amqp=1;
   
    YY_BUFFER_STATE yy_scan_string(const char *str);
    
    

%}


%START AMQP
%START MQTT1
%START MQTT2
%START MQTT3
%START COAP_OPTION
%START COAP_COUNTER
%START COAP_TOKEN

digit       [\x00-\x7F]
alpha       [\x80-\xFF][\x00-\x7F]
beta        [\x80-\xFF][\x80-\xFF][\x00-\x7F]
gamma       [\x80-\xFF][\x80-\xFF][\x80-\xFF][\x00-\x7F]
mqtt_init   ({digit}|{alpha}|{beta}|{gamma})
coap_init   [\x40|\x41|\x42|\x43|\x44|\x45|\x46|\x47|\x48|\x50|\x51|\x52|\x53|\x54|\x55|\x56|\x57|\x58|\x60|\x61|\x62|\x63|\x64|\x65|\x66|\x67|\x68|\x70|\x71|\x72|\x73|\x74|\x75|\x76|\x77|\x78]

%%

<AMQP>.* {

int lenght = strlen(yytext);

lunghezza_amqp = lunghezza_amqp - lenght;

if ( lunghezza_amqp == 0 ) 
{
  printf("%s\n", "E' amqp");
}
BEGIN 0;


}                           

<COAP_COUNTER>[\x00-\xFF] {

lunghezza_coap --;

if ( lunghezza_coap == 0 )

{

  BEGIN 0;

  BEGIN COAP_OPTION;

}

}

<COAP_OPTION><<EOF>> {

if ( lunghezza_coap == 0 ) {

printf("%s\n","E' Coap" );

BEGIN 0;

}

}

<COAP_OPTION>\xFF {

printf("%s\n","E' coap" );

}

<COAP_OPTION>([\x00-\x0C])|([\x10-\x1C])|([\x20-\x2C])|([\x30-\x3C])|([\x40-\x4C])|([\x50-\x5C])|([\x60-\x6C])|([\x70-\x7C])|([\x80-\x8C])|([\x90-\x9C])|([\xA0-\xAC])|([\xB0-\xBC])|([\xC0-\xCC]) {
  
  lunghezza_coap = ( ( yytext[0] ) & 0x0f );
  
  BEGIN 0;

  BEGIN COAP_COUNTER;
  
  }

<COAP_OPTION>((\x0D)|(\x1D)|(\x2D)|(\x3D)|(\x4D)|(\x5D)|(\x6D)|(\x7D)|(\x8D)|(\x9D)|(\xAD)|(\xBD)|(\xCD))[\x00-\xFF] {
  
  lunghezza_coap =  yytext[1] + 13 ;
  
  BEGIN 0;
  
  BEGIN COAP_COUNTER;
  
  }

<COAP_OPTION>(\x0E)|(\x1E)|(\x2E)|(\x3E)|(\x4E)|(\x5E)|(\x6E)|(\x7E)|(\x8E)|(\x9E)|(\xAE)|(\xBE)|(\xCE)[\x00-\xFF][\x00-\xFF] {
  
  lunghezza_coap =  ( ( ( yytext[1] ) * 256 ) + yytext[2] ) + 269 ;
  
  BEGIN 0;

  BEGIN COAP_COUNTER;
  
  }

<COAP_OPTION>((\xD0)|(\xD1)|(\xD2)|(\xD3)|(\xD4)|(\xD5)|(\xD6)|(\xD7)|(\xD8)|(\xD9)|(\xDA)|(\xDB)|(\xDC))[\x00-\xFF] {
  
  lunghezza_coap = ( ( yytext[0] ) & 0x0f );
  
  BEGIN 0;

  BEGIN COAP_COUNTER;
  
  }

<COAP_OPTION>((\xE0)|(\xE1)|(\xE2)|(\xE3)|(\xE4)|(\xE5)|(\xE6)|(\xE7)|(\xE8)|(\xE9)|(\xEA)|(\xEB)|(\xEC))[\x00-\xFF][\x00-\xFF] {
 
  lunghezza_coap = ( ( yytext[0] ) & 0x0f );
  
  BEGIN 0;

  BEGIN COAP_COUNTER;
  
  }

<COAP_OPTION>(\xDD)[\x00-\xFF][\x00-\xFF] {
 
  lunghezza_coap =  yytext[2] + 13 ;
  
  BEGIN 0;

  BEGIN COAP_COUNTER;


}

<COAP_OPTION>(\xDE)[\x00-\xFF][\x00-\xFF][\x00-\xFF] {
 
  lunghezza_coap = ( ( ( yytext[2] ) * 256 ) + yytext[3] ) + 269 ;
  
  BEGIN 0;
  
  BEGIN COAP_COUNTER;


}

<COAP_OPTION>(\xED)[\x00-\xFF][\x00-\xFF][\x00-\xFF] {
 
  lunghezza_coap =  yytext[3] + 13 ;
  
  BEGIN 0;
  
  BEGIN COAP_COUNTER;


}

<COAP_OPTION>(\xEE)[\x00-\xFF][\x00-\xFF][\x00-\xFF][\x00-\xFF] {
 
  lunghezza_coap =  ( ( ( yytext[3] ) * 256 ) + yytext[4] ) + 269 ;
  
  BEGIN 0;
  
  BEGIN COAP_COUNTER;


}




<COAP_TOKEN>[\x00-\xFF] {

lunghezza_coap--;

if ( lunghezza_coap == 0 )

{

  BEGIN 0;

  BEGIN COAP_OPTION;

}


}

<MQTT1>.* {

int lenght = strlen(yytext);

lunghezza_mqtt = lunghezza_mqtt - lenght;

if ( lunghezza_mqtt == 0 ) 
{
  printf("%s\n", "E' mqtt, pacchetto Publish");
}

BEGIN 0;

}


<MQTT2>.*  {

int lenght = strlen(yytext);

lunghezza_mqtt = lunghezza_mqtt - lenght;

if ( lunghezza_mqtt == 0 )
{
  printf("%s\n", "E' mqtt, pacchetto Subscribe");
}

BEGIN 0;

}

<MQTT3>.*  {

int lenght = strlen(yytext);

lunghezza_mqtt = lunghezza_mqtt - lenght;

if ( lunghezza_mqtt == 0 ) 
{
  printf("%s\n", "E' mqtt, pacchetto Unsubscribe");
}

BEGIN 0;

}




<INITIAL>\x10({mqtt_init})\x00\x04\x4d\x51\x54\x54\x04. {

printf("%s\n", "E' mqtt, Pacchetto Connect");

}

<INITIAL>\x20\x02(\x00(\x00|\x01|\x02|\x03|\x04|\x05))|(\x01(\x00|\x01|\x02|\x03|\x04|\x05)) {

printf("%s\n", "E' mqtt, Pacchetto Connack");

}

<INITIAL>\x30({digit}) { lunghezza_mqtt = yytext[1] ;  BEGIN MQTT1; }

<INITIAL>\x30({alpha}) { lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ;  BEGIN MQTT1 ; }

<INITIAL>\x30({beta})  { lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x30({gamma}) { lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1; }

<INITIAL>\x31({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x31({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x31({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x31({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x32({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x32({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x32({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x32({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x33({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x33({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x33({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x33({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x34({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x34({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x34({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x34({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x35({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x35({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x35({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x35({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x38({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x38({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x38({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x38({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x39({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x39({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x39({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x39({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x3A({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x3A({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x3A({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x3A({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x3B({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x3B({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x3B({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x3B({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x3C({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x3C({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x3C({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x3C({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x3D({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x3D({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x3D({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x3D({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

<INITIAL>\x3E({digit}) {lunghezza_mqtt = yytext[1] ; BEGIN MQTT1; }

<INITIAL>\x3E({alpha}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT1; }

<INITIAL>\x3E({beta})  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT1; }

<INITIAL>\x3E({gamma}) {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT1;}

 

<INITIAL>\x40\x02[\x00-\xFF][\x00-\xFF]  {

printf("%s\n","E' mqtt, Pacchetto Puback" ); 

}

<INITIAL>\x50\x02[\x00-\xFF][\x00-\xFF] {

printf("%s\n","E' mqtt, Pacchetto Pubrec" ); 

}

<INITIAL>\x62\x02[\x00-\xFF][\x00-\xFF]  { 

printf("%s\n","E' mqtt Pacchetto Pubrel");

}

<INITIAL>\x70\x02[\x00-\xFF][\x00-\xFF]  {

printf("%s\n","E' mqtt Pacchetto Pubcomp");

}

<INITIAL>\x82({digit})\x00\x0A {lunghezza_mqtt = yytext[1] ; BEGIN MQTT2; }

<INITIAL>\x82({alpha})\x00\x0A  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT2; }

<INITIAL>\x82({beta})\x00\x0A   {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT2; }

<INITIAL>\x82({gamma})\x00\x0A  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT2;}



<INITIAL>\x90({mqtt_init})[\x00-\xFF][\x00-\xFF](\x00|\x01|\x02|\x80)* {

printf("%s\n","E' mqtt Pacchetto Suback ");

}

<INITIAL>\xA2({digit})[\x00-\xFF][\x00-\xFF]  {lunghezza_mqtt = yytext[1] ; BEGIN MQTT3; }


<INITIAL>\xA2({alpha})[\x00-\xFF][\x00-\xFF]  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) ; BEGIN MQTT3; }


<INITIAL>\xA2({beta})[\x00-\xFF][\x00-\xFF]   {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ); BEGIN MQTT3; }


<INITIAL>\xA2({gamma})[\x00-\xFF][\x00-\xFF]  {lunghezza_mqtt = yytext[1] + ( yytext[2] * 128 ) + ( yytext[3] * 16384 ) + ( yytext[4] * 2097152 ); BEGIN MQTT3;}


<INITIAL>\xB0\x02[\x00-\xFF][\x00-\xFF]  {

printf("%s\n","E' mqtt Pacchetto Unsuback ");

}

<INITIAL>\xC0\x00 {

printf("%s\n","E' mqtt Pacchetto Pingreq ");


}

<INITIAL>\xD0\x00  {

printf("%s\n","E' mqtt Pacchetto Pingresp ");

}

<INITIAL>\xE0\x00  {

printf("%s\n","E' mqtt Pacchetto Disconnect ");


}

<INITIAL>{coap_init}(\x00|\x01|\x02|\x03|\x04|[\x41-\x45]|[\x80-\x86]|\x8C|\x8D|\x8F|[\xA0-\xA5])[\x00-\xFF][\x00-\xFF] {


lunghezza_coap = ( ( yytext[0] ) & 0x0f ) ; 

if ( lunghezza_coap == 0 )

{

BEGIN COAP_OPTION;

} else {

BEGIN COAP_TOKEN;  

}

}

<INITIAL>(\x01|\x02|\x03|\x04)[\x00-\xFF][\x00-\xFF][\x00-\xFF][\x00-\xFF][\x00-\xFF][\x00-\xFF] {

BEGIN AMQP;

lunghezza_amqp = lunghezza_amqp + ( ( ( yytext[3] ) * 16777216 ) + ( ( yytext[4] ) * 65536 ) + ( ( yytext[5] ) * 256 ) + yytext[6] ) ;


}


<INITIAL>"AMQP0091" {

printf("%s\n", "E' amqp");

}


[ \t\n]         ;/* skip whitespace */

.               exit(0);

%%
int main(int, char**) {
  
  
 // char prova[] = {0x42,0x01,0x44,0x45,0x44,0x22,0x45,0x55,0x67}; 
 //  yy_scan_bytes(prova,4);
  
  yylex();

}
