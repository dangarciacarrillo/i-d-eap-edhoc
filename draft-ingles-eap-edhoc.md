---
title: Using the Extensible Authentication Protocol with Ephemeral Diffie-Hellman over COSE (EDHOC)
docname: draft-ingles-eap-edhoc-02
abbrev: EAP-EDHOC

ipr: trust200902
area: SEC
workgroup: EMU Working Group
cat: std
consensus: true

coding: utf-8
pi: # can use array (if all yes) or hash here
  toc: yes
  sortrefs: yes
  symrefs: yes
  tocdepth: 3

author:
- name: Eduardo Ingles-Sanchez
  surname: Ingles-Sanchez
  org: University of Murcia
  abbrev: University of Murcia
  street: Murcia  30100
  country: Spain
  email: eduardo.ingles@um.es
- name: Dan Garcia-Carrillo
  surname: Garcia-Carrillo
  org: University of Oviedo
  abbrev: University of Oviedo
  street: Gijon, Asturias  33203
  country: Spain
  email: garciadan@uniovi.es
- name: Rafael Marin-Lopez
  surname: Marin-Lopez
  org: University of Murcia
  abbrev: University of Murcia
  street: Murcia  30100
  country: Spain
  email: rafa@um.es
- name: Göran Selander
  surname: Selander
  org: Ericsson
  abbrev: Ericsson
  street: SE-164 80 Stockholm
  country: Sweden
  email: goran.selander@ericsson.com
- name: John Preuß Mattsson
  initials: J
  surname: Preuß Mattsson
  org: Ericsson
  abbrev: Ericsson
  street: SE-164 80 Stockholm
  country: Sweden
  email: john.mattsson@ericsson.com


normative:

   RFC2119:
   RFC3748:
   RFC4137:
   RFC5216:
   RFC7542:
   RFC8174:
   I-D.ietf-lake-edhoc:

informative:

  RFC7252:
  RFC7593:
  RFC8613:
  RFC8949:
  RFC8152:
  RFC5280:

  RFC2637:
  RFC2661:
  RFC6066:
  RFC8446:
  RFC1661:
  RFC2865:
  RFC6733:
  RFC5191:  
  RFC6960:
  I-D.ietf-core-oscore-edhoc:



--- abstract

The Extensible Authentication Protocol (EAP), defined in RFC 3748, provides a standard mechanism for support of multiple authentication methods.
This document specifies the use of EAP-EDHOC with Ephemeral Diffie-Hellman Over COSE (EDHOC).
EDHOC provides a lightweight authenticated Diffie-Hellman key exchange with ephemeral keys, using COSE (RFC 8152) to provide security services efficiently encoded in CBOR (RFC 8949).
This document also provides guidance on authentication and authorization for EAP-EDHOC.

--- middle

# Introduction

The Extensible Authentication Protocol (EAP), defined in {{RFC3748}}, provides a standard mechanism for support of multiple authentication methods.
This document specifies the EAP authentication method EAP-EDHOC which uses COSE defined credential-based mutual authentication, utilising the EDHOC protocol cipher suite negotiation and establishment of shared secret keying material.
Ephemeral Diffie-Hellman Over COSE (EDHOC, {{I-D.ietf-lake-edhoc}}) is a very compact and lightweight authenticated key exchange protocol designed for highly constrained settings.
The main objective for EDHOC is to be a matching security handshake protocol to OSCORE {{RFC8613}}, i.e., to provide authentication and session key establishment for IoT use cases such as those built on CoAP {{RFC7252}} involving 'things' with embedded microcontrollers, sensors, and actuators.
 EDHOC reuses the same lightweight primitives as OSCORE, CBOR {{RFC8949}} and COSE {{RFC8152}}, and specifies the use of CoAP but is not bound to a particular transport.
The EAP-EDHOC method will enable the integration of EDHOC in different applications and use cases making use of the EAP framework.


# Conventions and Definitions

{::boilerplate bcp14-tagged}


# Protocol Overview {#overview}

## Overview of the EAP-EDHOC Conversation

The EDHOC protocol running between an Initiator and a Responder consists of three mandatory messages (message_1, message_2, message_3), an optional message_4, and an error message. EAP-EDHOC uses all messages in the exchange, and message_4 is mandatory, as alternate success indication.

After receiving an EAP-Request packet with EAP-Type=EAP-EDHOC as described in this document, the conversation will continue with the EDHOC protocol encapsulated in the data fields of EAP-Response and EAP-Request packets. When EAP-EDHOC is used, the formatting and processing of the EDHOC message SHALL be done as specified in {{I-D.ietf-lake-edhoc}}. This document only lists additional and different requirements, restrictions, and processing compared to {{I-D.ietf-lake-edhoc}}.



### Authentication

EAP-EDHOC authentication credentials can be of any type supported by COSE and be transported or referenced by EDHOC.

EAP-EDHOC provides forward secrecy by exchange of ephemeral Diffie-Hellman public keys in message_1 and message_2.

The optimization combining the execution of EDHOC with the first subsequent OSCORE transaction specified in {{I-D.ietf-core-oscore-edhoc}} is not supported in this EAP method.

~~~~~~~~~~~~~~~~~~~~~~~
[Editor's note: making EAP-EDHOC a tunnelled EAP method may be considered in the future.]
~~~~~~~~~~~~~~~~~~~~~~~

Figure 1 shows an example message flow for a successful EAP-EDHOC.

~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                           EAP-Request/Identity        |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity (Privacy-Friendly)            |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                     (EDHOC Start)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                 (EDHOC message_2)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Request/  |
    |                                   EAP-Type=EAP-EDHOC  |
    |                                    (EDHOC message_4)  |
    | <---------------------------------------------------  |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |  ---------------------------------------------------> |
    |                                        EAP-Success    |
    | <---------------------------------------------------  |
    +                                                       +
~~~~~~~~~~~~~~~~~~~~~~~
{: #message-flow title="EAP-EDHOC Mutual Authentication" artwork-align="center"}


### Transport and Message Correlation

EDHOC is not bound to a particular transport layer and can even be used in environments without IP. Nonetheless, EDHOC specification has a set of requirements for its transport protocol {{I-D.ietf-lake-edhoc}}. These include handling message loss, reordering, duplication, fragmentation, demultiplex EDHOC messages from other types of messages, denial-of-service protection, and message correlation. All these requirements are fulfilled either by the EAP protocol, EAP method or EAP lower layer, as specified in {{RFC3748}}. 

For message loss, this can be either fulfilled by the EAP protocol or the EAP lower layer, as retransmissions can occur both in the lower layer and the EAP layer when EAP is run over a reliable lower layer. In other words, the EAP layer will do the retransmissions if the EAP lower layer cannot do it.

For reordering, EAP is reliant on the EAP lower layer ordering guarantees for correct operation.

For duplication and message correlation, EAP has the Identifier field, which provides both the peer and authenticator with the ability to detect duplicates and match a request with a response.

Fragmentation is defined by this EAP method, see {{fragmentation}}. The EAP framework {{RFC3748}} specifies that EAP methods need to provide fragmentation and reassembly if EAP packets can exceed the minimum MTU of 1020 octets.

To demultiplex EDHOC messages from other types of messages, EAP provides the Code field.

This method does not provide other mitigation against denial-of-service than EAP {{RFC3748}}.



### Termination


If the EAP-EDHOC peer authenticates successfully, the EAP-EDHOC server MUST send an EAP-Request packet with EAP-Type=EAP-EDHOC containing message_4 as a protected success indication.

If the EAP-EDHOC server authenticates successfully, the EAP-EDHOC peer MUST send an EAP-Response message with EAP-Type=EAP-EDHOC containing no data. Finally, the EAP-EDHOC server sends an EAP-Success.

{{message1-reject}}, {{message2-reject}} and {{message3-reject}} illustrate message flows in several cases where the EAP-EDHOC peer or EAP-EDHOC server sends an EDHOC error message.

{{message1-reject}} shows an example message flow where the EAP-EDHOC server rejects message_1 with an EDHOC error message.

~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                           EAP-Request/Identity        |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity (Privacy-Friendly)            |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                     (EDHOC Start)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                   (EDHOC error)       |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                                        EAP-Failure    |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message1-reject title="EAP-EDHOC Server rejection of message_1" artwork-align="center"}

{{message2-reject}} shows an example message flow where the EAP-EDHOC server authentication is unsuccessful and the EAP-EDHOC peer sends an EDHOC error message.

~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                           EAP-Request/Identity        |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity (Privacy-Friendly)            |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                     (EDHOC Start)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                 (EDHOC message_2)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC error)                                       |
    | ----------------------------------------------------> |
    |                                        EAP-Failure    |
    | <---------------------------------------------------- |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message2-reject title="EAP-EDHOC Peer rejection of message_2" artwork-align="center"}

{{message3-reject}} shows an example message flow where the EAP-EDHOC server authenticates to the EAP-EDHOC peer successfully, but the EAP-EDHOC peer fails to authenticate to the EAP-EDHOC server and the server sends an EDHOC error message.



~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                           EAP-Request/Identity        |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity (Privacy-Friendly)            |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                     (EDHOC Start)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                 (EDHOC message_2)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                     (EDHOC error)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                                        EAP-Failure    |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message3-reject title="EAP-EDHOC Server rejection of message_3" artwork-align="center"}


{{message3-reject}} shows an example message flow where the EAP-EDHOC server sends the EDHOC message_4 to the EAP peer, but the success indication fails, and the peer sends an EDHOC error message.

~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                           EAP-Request/Identity        |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity (Privacy-Friendly)            |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                     (EDHOC Start)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                 (EDHOC message_2)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3)                                   |
    | ----------------------------------------------------> |
    |                                         EAP-Request/  |
    |                                   EAP-Type=EAP-EDHOC  |
    |                                    (EDHOC message_4)  |
    | <---------------------------------------------------  |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC error)                                       |
    | ----------------------------------------------------> |
    |                                        EAP-Failure    |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message4-reject title="EAP-EDHOC Peer rejection of message_4" artwork-align="center"}


### Identity

It is RECOMMENDED to use anonymous NAIs {{RFC7542}} in the Identity Response as such identities are routable and privacy-friendly.

While opaque blobs are allowed by {{RFC3748}}, such identities are NOT RECOMMENDED as they are not routable and should only be considered in local deployments where the EAP-EDHOC peer, EAP authenticator, and EAP-EDHOC server all belong to the same network.

Many client certificates contain an identity such as an email address, which is already in NAI format. When the client certificate contains an NAI as subject name or alternative subject name, an anonymous NAI SHOULD be derived from the NAI in the certificate; See section {{privacy}}.



### Privacy

EAP-EDHOC peer and server implementations supporting EAP-EDHOC MUST support anonymous Network Access Identifiers (NAIs) (Section 2.4 of {{RFC7542}}).
A client supporting EAP-EDHOC MUST NOT send its username (or any other permanent identifiers) in cleartext in the Identity Response (or any message used instead of the Identity Response). Following {{RFC7542}}, it is RECOMMENDED to omit the username (i.e., the NAI is @realm), but other constructions such as a fixed username (e.g., anonymous@realm) or an encrypted username (e.g., xCZINCPTK5+7y81CrSYbPg+RKPE3OTrYLn4AQc4AC2U=@realm) are allowed. Note that the NAI MUST be a UTF-8 string as defined by the grammar in Section 2.2 of {{RFC7542}}.

EAP-EDHOC  is always used with privacy. This does not add any extra round trips and the message flow with privacy is just the normal message flow as shown in {{message-flow}}.



### Fragmentation

EAP-EDHOC fragmentation support is provided through addition of a flags octet within the EAP-Response and EAP-Request packets, as well as a (conditional) EAP-EDHOC Message Length field of four octets.
 To do so, the EAP request and response messages of EAP-EDHOC have a set of information fields that allow for the specification of the fragmentation process (See section {{detailed-description}} for the detailed description). Of these fields, we will highlight the one that contains the flag octet, which is used to steer the fragmentation process. If the L bit is set, we are specifying that the next message will be fragmented and that in such a message we can also find the length of the message.


Implementations MUST NOT set the L bit in unfragmented messages, but they MUST accept unfragmented messages with and without the L bit set.
Some EAP implementations and access networks may limit the number of EAP packet exchanges that can be handled.
To avoid fragmentation, it is RECOMMENDED to keep the sizes of EAP-EDHOC peer, EAP-EDHOC server, and trust anchor authentication credentials small and the length of the certificate chains short.
In addition, it is RECOMMENDED to use mechanisms that reduce the sizes of Certificate messages.


EDHOC is designed to perform well in constrained networks where message sizes are restricted for performance reasons. However, except for message_2, which by construction has an upper bound limited by a multiple of the hash function output, there are no specific message size limitations. With SHA-256 as hash function, message_2 cannot be longer than 8160 octets. The other three EAP-EDHOC messages do not have an upper bound. Furthermore, in the case of sending a certificate in a message instead of a reference, a certificate may in principle be as long as 16 MB.
Hence, the EAP-EDHOC messages sent in a single round may thus be larger than the MTU size or the maximum Remote Authentication Dail-In User Service (RADIUS) packet size of 4096 octets.  As a result, an EAP-EDHOC implementation MUST provide its own support for fragmentation and reassembly.

Since EAP is a simple ACK-NAK protocol, fragmentation support can be
   added in a simple manner. In EAP, fragments that are lost or damaged
   in transit will be retransmitted, and since sequencing information is
   provided by the Identifier field in EAP, there is no need for a
   fragment offset field as is provided in IPv4
   EAP-EDHOC fragmentation support is provided through the addition of a flags
   octet within the EAP-Response and EAP-Request packets, as well as a
   EDHOC Message Length field of four octets.  Flags include the Length
   included (L), More fragments (M), and EAP-EDHOC Start (S) bits.  The L
   flag is set to indicate the presence of the four-octet EDHOC Message
   Length field, and MUST be set for the first fragment of a fragmented
   EDHOC message or set of messages.  The M flag is set on all but the
   last fragment.  The S flag is set only within the EAP-EDHOC start
   message sent from the EAP server to the peer.  The EDHOC Message Length
   field is four octets, and provides the total length of the EDHOC
   message or set of messages that is being fragmented; this simplifies
   buffer allocation.

   When an EAP-EDHOC peer receives an EAP-Request packet with the M bit
   set, it MUST respond with an EAP-Response with EAP-Type=EAP-EDHOC and
   no data.  This serves as a fragment ACK.  The EAP server MUST wait
   until it receives the EAP-Response before sending another fragment.
   In order to prevent errors in the processing of fragments, the EAP server
   MUST increment the Identifier field for each fragment contained
   within an EAP-Request, and the peer MUST include this Identifier
   value in the fragment ACK contained within the EAP-Response.
   Retransmitted fragments will contain the same Identifier value.

Similarly, when the EAP server receives an EAP-Response with the M
   bit set, it MUST respond with an EAP-Request with EAP-Type=EAP-EDHOC
   and no data.  This serves as a fragment ACK.  The EAP peer MUST wait
   until it receives the EAP-Request before sending another fragment.
   In order to prevent errors in the processing of fragments, the EAP
   server MUST increment the Identifier value for each fragment ACK
   contained within an EAP-Request, and the peer MUST include this
   Identifier value in the subsequent fragment contained within an EAP-
   Response.

   In the case where the EAP-EDHOC mutual authentication is successful,
   and fragmentation is required, the conversation will appear as
   follows:

~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                           EAP-Request/Identity        |
    | <---------------------------------------------------- |
    |   EAP-Response/Identity (Privacy-Friendly)            |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                          (EDHOC Start, S bit set)     |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                 (EDHOC message_2,     |
    |                          Fragment 1: L,M bits set)    |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                           (Fragment 2: M bits set)    |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    | ----------------------------------------------------> |
    |                                      EAP-Request/     |
    |                                EAP-Type=EAP-EDHOC     |
    |                                       (Fragment 3)    |
    | <---------------------------------------------------- |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3,                                   |
    |    Fragment 1: L,M bits set)                          |
    | ----------------------------------------------------> |
    |   EAP-Request/                                        |
    |   EAP-Type=EAP-EDHOC                                  |
    | <---------------------------------------------------  |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3,                                   |
    |    Fragment 2: M bits set)                            |
    | ----------------------------------------------------> |
    |   EAP-Request/                                        |
    |   EAP-Type=EAP-EDHOC                                  |
    | <---------------------------------------------------  |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3,                                   |
    |    Fragment 3)                                        |
    | ----------------------------------------------------> |
    |                                         EAP-Request/  |
    |                                   EAP-Type=EAP-EDHOC  |
    |                                    (EDHOC message_4)  |
    | <---------------------------------------------------  |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |  ---------------------------------------------------> |
    |                                        EAP-Success    |
    | <---------------------------------------------------  |
    +                                                       +
~~~~~~~~~~~~~~~~~~~~~~~
{: title="Fragmentation example of EAP-EDHOC Authentication" artwork-align="center"}


## Identity Verification {#identity-verification}

The EAP peer identity provided in the EAP-Response/Identity is not authenticated by EAP-EDHOC. Unauthenticated information MUST NOT be used for accounting purposes or to give authorization. The authenticator and the EAP-EDHOC server MAY examine the identity presented in EAP-Response/Identity for purposes such as routing and EAP method selection. EAP-EDHOC servers MAY reject conversations if the identity does not match their policy.

The EAP server identity in the EDHOC server certificate is typically a fully qualified domain name (FQDN) in the SubjectAltName (SAN) extension. Since EAP-EDHOC deployments may use more than one EAP server, each with a different certificate, EAP peer implementations SHOULD allow for the configuration of one or more trusted root certificates (CA certificate) to authenticate the server certificate and one or more server names to match against the SubjectAltName (SAN) extension in the server certificate. If any of the configured names match any of the names in the SAN extension, then the name check passes. To simplify name matching, an EAP-EDHOC deployment can assign a name to represent an authorized EAP server and EAP Server certificates can include this name in the list of SANs for each certificate that represents an EAP-EDHOC server. If server name matching is not used, then it degrades the confidence that the EAP server with which it is interacting is authoritative for the given network. If name matching is not used with a public root CA, then effectively any server can obtain a certificate that will be trusted for EAP authentication by the peer.

The process of configuring a root CA certificate and a server name is non-trivial; therefore, automated methods of provisioning are RECOMMENDED. For example, the eduroam federation {{RFC7593}} provides a Configuration Assistant Tool (CAT) to automate the configuration process. In the absence of a trusted root CA certificate (user-configured or system-wide), EAP peers MAY implement a trust on first use (TOFU) mechanism where the peer trusts and stores the server certificate during the first connection attempt. The EAP peer ensures that the server presents the same stored certificate on subsequent interactions. The use of a TOFU mechanism does not allow for the server certificate to change without out-of-band validation of the certificate and is therefore not suitable for many deployments including ones where multiple EAP servers are deployed for high availability. TOFU mechanisms increase the susceptibility to traffic interception attacks and should only be used if there are adequate controls in place to mitigate this risk.




## Key Hierarchy

The key schedule for EDHOC is described in Section 4 of {{I-D.ietf-lake-edhoc}}. The Key_Material and Method-Id SHALL be derived from the PRK_exporter using the EDHOC-Exporter interface, see Section 4.2.1 of {{I-D.ietf-lake-edhoc}}.

Type is the value of the EAP Type field defined in Section 2 of {{RFC3748}}. For EAP-EDHOC, the Type field has the value TBD1.

~~~~~~~~~~~~~~~~~~~~~~~
Type        =  TBD1
MSK         =  EDHOC-Exporter(TBD2 ,<< Type >>, 64)
EMSK        =  EDHOC-Exporter(TBD3 ,<< Type >>, 64)
Method-Id   =  EDHOC-Exporter(TBD4, << Type >>, 64)
Session-Id  =  Type || Method-Id
~~~~~~~~~~~~~~~~~~~~~~~


EAP-EDHOC exports the MSK and the EMSK and does not specify how it is used by lower layers.

## Parameter Negotiation and Compliance Requirements

The EAP-EDHOC peers and EAP-EDHOC servers MUST comply with the compliance requirements (mandatory-to-implement cipher suites, signature algorithms, key exchange algorithms, extensions, etc.) defined in Section 7  of {{I-D.ietf-lake-edhoc}}.



## EAP State Machines

The EAP-EDHOC server sends message_4 in an EAP-Request as a protected success result indication.

EDHOC error messages SHOULD be considered failure result indication, as defined in {{RFC3748}}.
After sending or receiving an EDHOC error message, the EAP-EDHOC server may only send an EAP-Failure. EDHOC error messages are unprotected.

The keying material can be derived after the EDHOC message_2 has
been sent or received. Implementations following {{RFC4137}} can then
set the eapKeyData and aaaEapKeyData variables. 

The keying material can be made available to lower layers and the
authenticator after the authenticated success result indication has
been sent or received (message_4). Implementations following {{RFC4137}} can set the eapKeyAvailable and aaaEapKeyAvailable variables.



# Detailed Description of the EAP-EDHOC Protocol {#detailed-description}


## EAP-EDHOC Request Packet

   A summary of the EAP-EDHOC Request packet format is shown below.  The
   fields are transmitted from left to right.

~~~~~~~~~~~~~~~~~~~~~~~
   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Code      |   Identifier  |            Length             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |     Flags     |      EDHOC Message Length
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |   EDHOC Message Length        |       EDHOC Data...
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
~~~~~~~~~~~~~~~~~~~~~~~

Code

      1

  Identifier

      The Identifier field is one octet and aids in matching responses
      with requests.  The Identifier field MUST be changed on each
      Request packet.

   Length

      The Length field is two octets and indicates the length of the EAP
      packet including the Code, Identifier, Length, Type, and Data
      fields.  Octets outside the range of the Length field should be
      treated as Data Link Layer padding and MUST be ignored on
      reception.

   Type

      TBD1 -- EAP-EDHOC

   Flags

      0 1 2 3 4 5 6 7 8
      +-+-+-+-+-+-+-+-+
      |L M S R R R R R|
      +-+-+-+-+-+-+-+-+

      L = Length included
      M = More fragments
      S = EAP-EDHOC start
      R = Reserved

      The L bit (length included) is set to indicate the presence of the
      four-octet EDHOC Message Length field and MUST be set for the first
      fragment of a fragmented EDHOC message or set of messages.  The M
      bit (more fragments) is set on all but the last fragment.  The S
      bit (EAP-EDHOC start) is set in an EAP-EDHOC Start message.  This
      differentiates the EAP-EDHOC Start message from a fragment
      acknowledgement.  Implementations of this specification MUST set
      the reserved bits to zero and MUST ignore them on reception.

   EDHOC Message Length

      The EDHOC Message Length field is four octets and is present only
      if the L bit is set.  This field provides the total length of the
      EDHOC message or set of messages that is being fragmented.

   EDHOC data

      The EDHOC data consists of the encapsulated EDHOC packet in EDHOC
      message format.

## EAP-EDHOC Response Packet

A summary of the EAP-EDHOC Response packet format is shown below.
The fields are transmitted from left to right.

~~~~~~~~~~~~~~~~~~~~~~~
   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Code      |   Identifier  |            Length             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |     Flags     |      EDHOC Message Length
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |   EDHOC Message Length        |       EDHOC Data...
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
~~~~~~~~~~~~~~~~~~~~~~~

   Code

      2

   Identifier

      The Identifier field is one octet and MUST match the Identifier
      field from the corresponding request.

   Length

      The Length field is two octets and indicates the length of the EAP
      packet including the Code, Identifier, Length, Type, and Data
      fields.  Octets outside the range of the Length field should be
      treated as Data Link Layer padding and MUST be ignored on
      reception.

   Type

      TBD1 -- EAP-EDHOC

 Flags

      0 1 2 3 4 5 6 7 8
      +-+-+-+-+-+-+-+-+
      |L M R R R R R R|
      +-+-+-+-+-+-+-+-+

      L = Length included
      M = More fragments
      R = Reserved

      The L bit (length included) is set to indicate the presence of the
      four-octet EDHOC Message Length field, 
      and MUST be set for the first
      fragment of a fragmented EDHOC message or set of messages.  The M
      bit (more fragments) is set on all but the last fragment.
      Implementations of this specification MUST set the reserved bits
      to zero and MUST ignore them on reception.

   EDHOC Message Length

      The EDHOC Message Length field is four octets and is present only
      if the L bit is set.  This field provides the total length of the
      EDHOC message or set of messages that is being fragmented.

   EDHOC data

      The EDHOC data consists of the encapsulated EDHOC message.


# IANA Considerations {#iana}

## EAP Type

IANA has allocated EAP Type TBD1 for method EAP-EDHOC. The allocation has been updated to reference this document.

## EDHOC Exporter Label Registry

IANA has registered the following new labels in the "EDHOC Exporter Label" registry under the group name "Ephemeral Diffie-Hellman Over COSE (EDHOC)":

~~~~~~~~~~~~~~~~~~~~~~~
Label: TBD2
Description: MSK of EAP method EAP-EDHOC
~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~
Label: TBD3
Description: EMSK of EAP method EAP-EDHOC
~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~
Label: TBD4
Description: Method-Id of EAP method EAP-EDHOC
~~~~~~~~~~~~~~~~~~~~~~~
The allocations have been updated to reference this document.


# Security Considerations {#security}
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~


## Security Claims 
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~

Using EAP-EDHOC provides the security claims of EDHOC, which are described next.

  [1] Mutual authentication:
    The initiator and responder authenticate each other through the EDHOC exchage.    

  [2] Forward secrecy:
    Only ephemeral Diffie-Hellman methods are supported by EDHOC, which ensures that the compromise of one session key does not also compromise earlier sessions' keys.

  [3] Identity protection:
    EDHOC secures the Responder's credential identifier against passive attacks and the Initiator's credential identifier against active attacks. By listening in on the destination address used to transfer message_1, an active attacker can obtain the Responder's credential identification and send its own message_1 to the same address. 

  [4] Cryptographic negotiation:
    The list of supported cipher suites by the initiator must be in the order of preference. The cipher suites that the Responder supports must be on the list.

  [5] Integrity protection:
    EDHOC extends the message authentication coverage to new elements including algorithms, external authorization data, and earlier messages in addition to adding an explicit method type. This safeguards against a hacker inserting or repeating messages from another session. EDHOC also adds selection of connection identifiers and downgrade protected negotiation of cryptographic parameters



## Peer and Server Identities {#peer-identities}
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~
  The EAP-EDHOC peer name (Peer-Id) represents the identity to be used
   for access control and accounting purposes.  The Server-Id represents
   the identity of the EAP server.  Together the Peer-Id and Server-Id
   name the entities involved in deriving the MSK/EMSK.

   In EAP-EDHOC, the Peer-Id and Server-Id are determined from the subject
   or subjectAltName fields in the peer and server certificates.  Where the subjectAltName
   field is present in the peer or server certificate, the Peer-Id or
   Server-Id MUST be set to the contents of the subjectAltName.  If
   subject naming information is present only in the subjectAltName
   extension of a peer or server certificate, then the subject field
   MUST be an empty sequence and the subjectAltName extension MUST be
   critical.

   Where the peer identity represents a host, a subjectAltName of type
   dnsName SHOULD be present in the peer certificate.  Where the peer
   identity represents a user and not a resource, a subjectAltName of
   type rfc822Name SHOULD be used, conforming to the grammar for the
   Network Access Identifier (NAI) defined in [RFC7542].
   If a dnsName or rfc822Name are not available, other field types (for
   example, a subjectAltName of type ipAddress or
   uniformResourceIdentifier) MAY be used.

   A server identity will typically represent a host, not a user or a
   resource.  As a result, a subjectAltName of type dnsName SHOULD be
   present in the server certificate.  If a dnsName is not available
   other field types (for example, a subjectAltName of type ipAddress or
   uniformResourceIdentifier) MAY be used.

   Conforming implementations generating new certificates with Network
   Access Identifiers (NAIs) MUST use the rfc822Name in the subject
   alternative name field to describe such identities.  The use of the
   subject name field to contain an emailAddress Relative Distinguished
   Name (RDN) is deprecated, and MUST NOT be used.  The subject name
   field MAY contain other RDNs for representing the subject's identity.

   Where it is non-empty, the subject name field MUST contain an X.500
   distinguished name (DN).  If subject naming information is present
   only in the subject name field of a peer certificate and the peer
   identity represents a host or device, the subject name field SHOULD
   contain a CommonName (CN) RDN or serialNumber RDN.  If subject naming
   information is present only in the subject name field of a server
   certificate, then the subject name field SHOULD contain a CN RDN or
   serialNumber RDN.


   It is possible for more than one subjectAltName field to be present
   in a peer or server certificate in addition to an empty or non-empty
   subject distinguished name.  EAP-EDHOC implementations supporting
   export of the Peer-Id and Server-Id SHOULD export all the
   subjectAltName fields within Peer-Ids or Server-Ids, and SHOULD also
   export a non-empty subject distinguished name field within the Peer-
   Ids or Server-Ids.  All of the exported Peer-Ids and Server-Ids are
   considered valid.

   EAP-EDHOC implementations supporting export of the Peer-Id and Server-
   Id SHOULD export Peer-Ids and Server-Ids in the same order in which
   they appear within the certificate.  Such canonical ordering would
   aid in comparison operations and would enable using those identifiers
   for key derivation if that is deemed useful.  However, the ordering
   of fields within the certificate SHOULD NOT be used for access
   control.

## Certificate Validation
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~
 Since the EAP-EDHOC server is typically connected to the Internet, it
   SHOULD support validating the peer certificate using 
   [RFC5280] compliant path validation, including the ability to
   retrieve intermediate certificates that may be necessary to validate
   the peer certificate.

   Where the EAP-EDHOC server is unable to retrieve intermediate
   certificates, either it will need to be pre-configured with the
   necessary intermediate certificates to complete path validation or it
   will rely on the EAP-EDHOC peer to provide this information as part of
   the EDHOC exchange.

   In contrast to the EAP-EDHOC server, the EAP-EDHOC peer may not have
   Internet connectivity.  Therefore, the EAP-EDHOC server SHOULD provide
   its entire certificate chain minus the root to facilitate certificate
   validation by the peer.  The EAP-EDHOC peer SHOULD support validating
   the server certificate using [RFC5280] compliant path
   validation.

   Once a EDHOC session is established, EAP-EDHOC peer and server
   implementations MUST validate that the identities represented in the
   certificate are appropriate and authorized for use with EAP-EDHOC.  The
   authorization process makes use of the contents of the certificates
   as well as other contextual information.  While authorization
   requirements will vary from deployment to deployment, it is
   RECOMMENDED that implementations be able to authorize based on the
   EAP-EDHOC Peer-Id and Server-Id determined as described in Section {{peer-identities}}.

   In the case of the EAP-EDHOC peer, this involves ensuring that the
   certificate presented by the EAP-EDHOC server was intended to be used
   as a server certificate.  Implementations SHOULD use the Extended Key
   Usage (see [RFC5280]) extension and ensure that
   at least one of the following is true:

   1) The certificate issuer included no Extended Key Usage identifiers
      in the certificate.
   2) The issuer included the anyExtendedKeyUsage identifier in the
      certificate.
   3) The issuer included the id-kp-serverAuth identifier in the
      certificate.

[//]: # ( When performing this comparison, implementations MUST follow the validation rules specified in Section 3.1 of [RFC2818].)


   In the case of the server, this involves ensuring the certificate presented by
   the EAP-EDHOC peer was intended to be used as a client certificate.
   Implementations SHOULD use the Extended Key Usage (see [RFC5280]) extension and ensure that at least one of the
   following is true:

   1) The certificate issuer included no Extended Key Usage identifiers
      in the certificate.
   2) The issuer included the anyExtendedKeyUsage identifier in the
      certificate 
   3) The issuer included the id-kp-clientAuth identifier in the
      certificate (see [RFC5280]).

## Certificate Revocation
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~

Certificates are long-lived assertions of identity.  Therefore, it is
   important for EAP-EDHOC implementations to be capable of checking
   whether these assertions have been revoked.

   EAP-EDHOC peer and server implementations MUST support the use of
   Certificate Revocation Lists (CRLs); for details, see 
   [RFC5280].  EAP-EDHOC peer and server implementations SHOULD also
   support the Online Certificate Status Protocol (OCSP), described in
   "X.509 Internet Public Key Infrastructure Online Certificate Status
   Protocol - OCSP" [RFC6960].  OCSP messages are typically much smaller
   than CRLs, which can shorten connection times especially in
   bandwidth-constrained environments.  While EAP-EDHOC servers are
   typically connected to the Internet during the EAP conversation, an
   EAP-EDHOC peer may not have Internet connectivity until authentication
   completes.

   In the case where the peer is initiating a voluntary Layer 2 tunnel
   using PPTP [RFC2637] or L2TP [RFC2661], the peer will typically
   already have a PPP interface and Internet connectivity established at
   the time of tunnel initiation.

  There are a number of reasons (e.g., key compromise, CA compromise, privilege withdrawn, etc.) why EAP-EDHOC peer, EAP-EDHOC server, or sub-CA certificates have to be revoked before their expiry date. Revocation of the EAP-EDHOC server's certificate is complicated by the fact that the EAP-EDHOC peer may not have Internet connectivity until authentication completes. When EAP-EDHOC is used, the revocation status of all the certificates in the certificate chains MUST be checked (except the trust anchor). An implementation may use the Certificate Revocation List (CRL), Online Certificate Status Protocol (OSCP), or other standardized/proprietary methods for revocation checking. Examples of proprietary methods are non-standard formats for distribution of revocation lists as well as certificates with very short lifetime. EAP-EDHOC servers  MUST implement Certificate Status Requests (OCSP stapling) as specified in [RFC6066] and Section 4.4.2.1 of [RFC8446]. It is RECOMMENDED that EAP-EDHOC peers and EAP-EDHOC servers use OCSP stapling for verifying the status of the EAP-EDHOC server's certificate chain. When an EAP-EDHOC peer uses Certificate Status Requests to check the revocation status of the EAP-EDHOC server's certificate chain, it MUST treat a CertificateEntry (but not the trust anchor) without a valid CertificateStatus extension as invalid and abort the handshake with an appropriate alert. The OCSP information is carried in the CertificateEntry containing the associated certificate instead of a separate CertificateStatus message as in [RFC6066]. This enables sending OCSP information for all certificates in the certificate chain (except the trust anchor).To enable revocation checking in situations where EAP-EDHOC peers do not implement or use OCSP stapling, and where network connectivity is not available prior to authentication completion, EAP-EDHOC peer implementations MUST also support checking for certificate revocation after authentication completes and network connectivity is available. An EAP peer implementation SHOULD NOT trust the network (and any services) until it has verified the revocation status of the server certificate after receiving network connectivity. An EAP peer MUST use a secure transport to verify the revocation status of the server certificate. An EAP peer SHOULD NOT send any other traffic before revocation checking for the server certificate is complete.


## Packet Modification Attacks
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~

  The integrity protection of EAP-EDHOC packets does not extend to the
   EAP header fields (Code, Identifier, Length) or the Type or Flags
   fields.  As a result, these fields can be modified by an attacker.

  The only information that is integrity and replay protected in EAP-EDHOC are the parts of the EDHOC message that EDHOC protects. All other information in the EAP-EDHOC message exchange including EAP-Request and EAP-Response headers, the identity in the Identity Response, EAP-EDHOC packet header fields, Type, Flags, EAP-Success, and EAP-Failure can be modified, spoofed, or replayed. Protected EDHOC Error messages are protected failure result indications and enable the EAP-EDHOC peer and EAP-EDHOC server to determine that the failure result was not spoofed by an attacker. Protected failure result indications provide integrity and replay protection but MAY be unauthenticated. 


## Authorization
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~

EAP servers will usually require the EAP peer to provide a valid certificate and will fail the connection if one is not provided. Some deployments may permit no peer authentication for some or all connections. When peer authentication is not used, EAP-EDHOC server implementations MUST take care to limit network access appropriately for unauthenticated peers, and implementations MUST use resumption with caution to ensure that a resumed session is not granted more privilege than was intended for the original session. An example of limiting network access would be to invoke a vendor's walled garden or quarantine network functionality. EAP-EDHOC is typically encapsulated in other protocols such as PPP [RFC1661], RADIUS [RFC2865], Diameter [RFC6733], or the Protocol for Carrying Authentication for Network Access (PANA) [RFC5191]. The encapsulating protocols can also provide additional, non-EAP information to an EAP-EDHOC server. This information can include, but is not limited to, information about the authenticator, information about the EAP-EDHOC peer, or information about the protocol layers above or below EAP (MAC addresses, IP addresses, port numbers, Wi-Fi Service Set Identifiers (SSIDs), etc.). EAP-EDHOC servers implementing EAP-EDHOC inside those protocols can make policy decisions and enforce authorization based on a combination of information from the EAP-EDHOC exchange and non-EAP information. The identity presented in EAP-Response/Identity is not authenticated by EAP-EDHOC and is therefore trivial for an attacker to forge, modify, or replay. Authorization and accounting MUST be based on authenticated information such as information in the certificate. Note that the requirements for Network Access Identifiers (NAIs) specified in Section 4 of [RFC7542] still apply and MUST be followed. EAP-EDHOC servers MAY reject conversations based on non-EAP information provided by the encapsulating protocol, for example if the MAC address of the authenticator does not match the expected policy.In addition to allowing configuration of one or more trusted root certificates (CA certificate) to authenticate the server certificate and one or more server names to match against the SubjectAltName (SAN) extension, EAP peer implementations MAY allow binding the configured acceptable SAN to a specific CA (or CAs) that should have issued the server certificate to prevent attacks from rogue or compromised CAs.

## Privacy Considerations
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~

In this section, we only discuss the privacy properties of EAP-EDHOC. For privacy properties of EDHOC itself, see {{I-D.ietf-lake-edhoc}}. EAP-EDHOC sends the EDHOC messages encapsulated in EAP packets. Additionally, the EAP-EDHOC peer sends an identity in the first EAP-Response. The other fields in the EAP-EDHOC Request and the EAP-EDHOC Response packets do not contain any cleartext privacy-sensitive information. Tracking of users by eavesdropping on Identity Responses or certificates is a well-known problem in many EAP methods. When EAP-EDHOC is used, all certificates are encrypted, and the username part of the Identity Response is not revealed (e.g., using anonymous NAIs). Note that even though all certificates are encrypted, the server's identity is only protected against passive attackers while the client's identity is protected against both passive and active attackers. As with other EAP methods, even when privacy-friendly identifiers or EAP tunneling is used, the domain name (i.e., the realm) in the NAI is still typically visible. 
  How much privacy-sensitive information the domain name leaks is highly dependent on how many other users are using the same domain name in the particular access network. If all EAP-EDHOC peers have the same domain, no additional information is leaked. If a domain name is used by a small subset of the EAP-EDHOC peers, it may aid an attacker in tracking or identifying the user.Without padding, information about the size of the client certificate is leaked from the size of the EAP-EDHOC packets. The EAP-EDHOC packets sizes may therefore leak information that can be used to track or identify the user. If all client certificates have the same length, no information is leaked. 
  EAP-EDHOC peers SHOULD use padding; see Section 8.6 of {{I-D.ietf-lake-edhoc}} to reduce information leakage of certificate sizes.
  If anonymous NAIs are not used, the privacy-friendly identifiers need to be generated with care. The identities MUST be generated in a cryptographically secure way so that it is computationally infeasible for an attacker to differentiate two identities belonging to the same user from two identities belonging to different users in the same realm. This can be achieved, for instance, by using random or pseudo-random usernames such as random byte strings or ciphertexts and only using the pseudo-random usernames a single time. Note that the privacy-friendly usernames also MUST NOT include substrings that can be used to relate the identity to a specific user. Similarly, privacy-friendly usernames MUST NOT be formed by a fixed mapping that stays the same across multiple different authentications. 


## Pervasive Monitoring
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~

Pervasive monitoring refers to widespread surveillance of users. In the context of EAP-EDHOC, pervasive monitoring attacks can target EAP-EDHOC peer devices for tracking them (and their users) when they join a network. By encrypting more information, mandating the use of privacy, and always providing forward secrecy, EAP-EDHOC offers much better protection against pervasive monitoring. In addition to the privacy attacks discussed above, surveillance on a large scale may enable tracking of a user over a wide geographical area and across different access networks. Using information from EAP-EDHOC together with information gathered from other protocols increases the risk of identifying individual users. In EDHOC, key derivation mechanism provides forward secrecy for the traffic secrets. EDHOC does not provide a similar mechanism for MSK and EMSK. Implementation using the exported MSK and EMSK can achieve forward secrecy by frequently deriving new keys.



## Cross-Protocol Attacks
~~~~~~~~~~~~~~~~~~~~~~~
Editors Note: Fill this section
~~~~~~~~~~~~~~~~~~~~~~~
This is a new section when compared to [RFC5216].

Allowing the same certificate to be used in multiple protocols can potentially allow an attacker to authenticate via one protocol and then "resume" that session in another protocol. 

Section {{identity-verification}} suggests that certificates typically have one or more FQDNs in the SAN extension. However, those fields are for EAP validation only and do not indicate that the certificates are suitable for use with HTTPS or other protocols on the named host. 

Along with making sure that appropriate authorization information is available and used during resumption, using different certificates for different protocols is RECOMMENDED to help keep different protocol usages separate.


--- back


# Acknowledgments
{: numbered="no"}

Work on this document has in part been supported by the H2020 Projects IoTCrawler (grant agreement no. 779852) and INSPIRE-5Gplus (grant agreement no. 871808).

--- fluff
