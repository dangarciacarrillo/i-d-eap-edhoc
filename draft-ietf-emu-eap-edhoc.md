---
title: Using the Extensible Authentication Protocol with Ephemeral Diffie-Hellman over COSE (EDHOC)
docname: draft-ietf-emu-eap-edhoc-01
abbrev: EAP-EDHOC

ipr: trust200902
submissionType: IETF
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

   RFC9528:
   RFC2119:
   RFC3748:
   RFC4137:
   RFC7542:
   RFC8174:
   RFC9190:

informative:

  I-D.ietf-core-oscore-edhoc:
  RFC7252:
  RFC7593:
  RFC9052:
  RFC9053:
  RFC8613:
  RFC8949:
  


--- abstract

The Extensible Authentication Protocol (EAP), defined in RFC 3748, provides a standard mechanism for support of multiple authentication methods.
This document specifies the use of EAP-EDHOC with Ephemeral Diffie-Hellman Over COSE (EDHOC).
EDHOC provides a lightweight authenticated Diffie-Hellman key exchange with ephemeral keys, using COSE (RFC 9052, RFC 9053) to provide security services efficiently encoded in CBOR (RFC 8949).
This document also provides guidance on authentication and authorization for EAP-EDHOC.

--- middle

# Introduction

The Extensible Authentication Protocol (EAP), defined in {{RFC3748}}, provides a standard mechanism for support of multiple authentication methods.
This document specifies the EAP authentication method EAP-EDHOC which uses COSE-defined credential-based mutual authentication, utilizing the EDHOC protocol cipher suite negotiation and establishment of shared secret keying material.
Ephemeral Diffie-Hellman Over COSE (EDHOC, {{RFC9528}}) is a very compact and lightweight authenticated key exchange protocol designed for highly constrained settings.
The main objective for EDHOC is to be a matching security handshake protocol to OSCORE {{RFC8613}}, i.e., to provide authentication and session key establishment for IoT use cases such as those built on CoAP {{RFC7252}} involving 'things' with embedded microcontrollers, sensors, and actuators.
 EDHOC reuses the same lightweight primitives as OSCORE, CBOR {{RFC8949}} and COSE {{RFC9052}} {{RFC9053}} and specifies the use of CoAP but is not bound to a particular transport.
The EAP-EDHOC method will enable the integration of EDHOC in different applications and use cases using the EAP framework.


# Conventions and Definitions

{::boilerplate bcp14-tagged}


# Protocol Overview {#overview}

## Overview of the EAP-EDHOC Conversation


The EDHOC protocol running between an Initiator and a Responder
   consists of three mandatory messages (message_1, message_2,
   message_3), an optional message_4, and an error message.  EAP-EDHOC
   uses all messages in the exchange, and message_4 is mandatory, as an
   protected success indication.


After receiving an EAP-Request packet with EAP-Type=EAP-EDHOC as described in this document, the conversation will continue with the EDHOC protocol encapsulated in the data fields of EAP-Response and EAP-Request packets. When EAP-EDHOC is used, the formatting and processing of the EDHOC message SHALL be done as specified in {{RFC9528}}. This document only lists additional and different requirements, restrictions, and processing compared to {{RFC9528}}.



### Authentication

EAP-EDHOC authentication credentials can be of any type supported by COSE and be transported or referenced by EDHOC.

EAP-EDHOC provides forward secrecy by exchange of ephemeral Diffie-Hellman public keys in message_1 and message_2.

The optimization combining the execution of EDHOC with the first subsequent OSCORE transaction specified in {{I-D.ietf-core-oscore-edhoc}} is not supported in this EAP method.

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

EDHOC is not bound to a particular transport layer and can even be used in environments without IP. Nonetheless, EDHOC specification has a set of requirements for its transport protocol {{RFC9528}}. These include handling message loss, reordering, duplication, fragmentation, demultiplex EDHOC messages from other types of messages, denial-of-service protection, and message correlation. All these requirements are fulfilled by the EAP protocol, EAP method, or EAP lower layer, as specified in {{RFC3748}}. 


For message loss, this can be either fulfilled by the EAP layer or
   the EAP lower layer or both.


For reordering, EAP relies on the EAP lower layer ordering guarantees, for correct operation.

For duplication and message correlation, EAP has the Identifier field, which allows both the peer and authenticator to detect duplicates and match a request with a response.

Fragmentation is defined by this EAP method, see {{fragmentation}}. The EAP framework {{RFC3748}}, specifies that EAP methods need to provide fragmentation and reassembly if EAP packets can exceed the minimum MTU of 1020 octets.

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

{{message3-reject}} shows an example message flow where the EAP-EDHOC server authenticates to the EAP-EDHOC peer successfully, but the EAP-EDHOC peer fails to authenticate to the EAP-EDHOC server, and the server sends an EDHOC error message.



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


{{message3-reject}} shows an example message flow where the EAP-EDHOC server
   sends the EDHOC message_4 to the EAP peer, but the protected success indication
   fails, and the peer sends an EDHOC error message.

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

Many client certificates contain an identity such as an email address, which is already in NAI format. When the client certificate contains an NAI as subject name or alternative subject name, an anonymous NAI SHOULD be derived from the NAI in the certificate; See {{privacy}}.



### Privacy

EAP-EDHOC peer and server implementations supporting EAP-EDHOC MUST support anonymous Network Access Identifiers (NAIs) (Section 2.4 of {{RFC7542}}).
A client supporting EAP-EDHOC MUST NOT send its username (or any other permanent identifiers) in cleartext in the Identity Response (or any message used instead of the Identity Response). Following {{RFC7542}}, it is RECOMMENDED to omit the username (i.e., the NAI is @realm), but other constructions such as a fixed username (e.g., anonymous@realm) or an encrypted username (e.g., xCZINCPTK5+7y81CrSYbPg+RKPE3OTrYLn4AQc4AC2U=@realm) are allowed. Note that the NAI MUST be a UTF-8 string as defined by the grammar in Section 2.2 of {{RFC7542}}.

EAP-EDHOC is always used with privacy. This does not add any extra round trips and the message flow with privacy is just the normal message flow as shown in {{message-flow}}.



### Fragmentation

EAP-EDHOC fragmentation support is provided through the addition of a flags octet within the EAP-Response and EAP-Request packets, as well as a (conditional) EAP-EDHOC Message Length field that can be one to four octets.

 To do so, the EAP request and response messages of EAP-EDHOC have a set of information fields that allow for the specification of the fragmentation process (See  {{detailed-description}} for the detailed description). Of these fields, we will highlight the one that contains the flag octet, which is used to steer the fragmentation process. If the L bits are set, we are specifying that the message will be fragmented and the length of the message, which is in the EAP-EDHOC Message Length field. 


Implementations MUST NOT set the L bit in unfragmented messages, but they MUST accept unfragmented messages with and without the L bit set.
Some EAP implementations and access networks may limit the number of EAP packet exchanges that can be handled.
To avoid fragmentation, it is RECOMMENDED to keep the sizes of EAP-EDHOC peer, EAP-EDHOC server, and trust anchor authentication credentials small and the length of the certificate chains short.
In addition, it is RECOMMENDED to use mechanisms that reduce the sizes of Certificate messages.


EDHOC is designed to perform well in constrained networks where message sizes are restricted for performance reasons.
In the basic message construction, the size of plaintext in message_2 is limited to the length of the output of the key derivation function which in turn is decided by the EDHOC hash function. For example, with SHA-256 as EDHOC hash algorithm, the maximum size of plaintext in message_2 is 8160 bytes.
However, EDHOC also defines an optional backward compatible method for handling arbitrarily long message_2 plaintext sizes, see Appendix G in {{RFC9528}}. The other three EAP-EDHOC messages do not have an upper bound.

Furthermore, in the case of sending a certificate in a message instead of a reference, a certificate may in principle be as long as 16 MB.
Hence, the EAP-EDHOC messages sent in a single round may thus be larger than the MTU size or the maximum Remote Authentication Dial-In User Service (RADIUS) packet size of 4096 octets.  As a result, an EAP-EDHOC implementation MUST provide its support for fragmentation and reassembly.

Since EAP is a simple ACK-NAK protocol, fragmentation support can be
  easily added. In EAP, fragments that are lost or damaged
   in transit will be retransmitted, and since sequencing information is
   provided by the Identifier field in EAP, there is no need for a
   fragment offset field as is provided in IPv4
   EAP-EDHOC fragmentation support is provided through the addition of flags
   octet within the EAP-Response and EAP-Request packets, as well as a
   EDHOC Message Length field.  Flags include the Length
   included (L), More fragments (M), and EAP-EDHOC Start (S) bits.  The L
   flag is set to indicate the presence of the EDHOC Message
   Length field, and MUST be set for the first fragment of a fragmented
   EDHOC message.  The M flag is set on all but the
   last fragment.  The S flag is set only within the EAP-EDHOC start
   message sent from the EAP server to the peer.  The EDHOC Message Length
   field provides the total length of the EDHOC
   message that is being fragmented; this simplifies
   buffer allocation.

   When an EAP-EDHOC peer receives an EAP-Request packet with the M bit
   set, it MUST respond with an EAP-Response with EAP-Type=EAP-EDHOC and
   no data.  This serves as a fragment ACK.  The EAP server MUST wait
   until it receives the EAP-Response before sending another fragment.
   To prevent errors in the processing of fragments, the EAP server
   MUST increment the Identifier field for each fragment contained
   within an EAP-Request, and the peer MUST include this Identifier
   value in the fragment ACK contained within the EAP-Response.
   Retransmitted fragments will contain the same Identifier value.

Similarly, when the EAP-EDHOC server receives an EAP-Response with the M
   bit set, it MUST respond with an EAP-Request with EAP-Type=EAP-EDHOC
   and no data.  This serves as a fragment ACK.  The EAP peer MUST wait
   until it receives the EAP-Request before sending another fragment.
   To prevent errors in the processing of fragments, the EAP
   server MUST increment the Identifier value for each fragment ACK
   contained within an EAP-Request, and the peer MUST include this
   Identifier value in the subsequent fragment contained within an EAP-
   Response.

   In the case where the EAP-EDHOC mutual authentication is successful,
   and fragmentation is required, the conversation will appear as
   follows:

~~~~~~~~~~~~~~~~~~~~~~~
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                               EAP-Request/Identity    |
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
    |                                         EAP-Request/  |
    |                                   EAP-Type=EAP-EDHOC  |
    | <---------------------------------------------------  |
    |   EAP-Response/                                       |
    |   EAP-Type=EAP-EDHOC                                  |
    |   (EDHOC message_3,                                   |
    |    Fragment 2: M bits set)                            |
    | ----------------------------------------------------> |
    |                                         EAP-Request/  |
    |                                   EAP-Type=EAP-EDHOC  |
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

The process of configuring a root CA certificate and a server name is non-trivial; therefore, automated methods of provisioning are RECOMMENDED. For example, the eduroam federation {{RFC7593}} provides a Configuration Assistant Tool (CAT) to automate the configuration process. In the absence of a trusted root CA certificate (user-configured or system-wide), EAP peers MAY implement a Trust On First Use (TOFU) mechanism where the peer trusts and stores the server certificate during the first connection attempt. The EAP peer ensures that the server presents the same stored certificate on subsequent interactions. The use of a TOFU mechanism does not allow for the server certificate to change without out-of-band validation of the certificate and is therefore not suitable for many deployments including ones where multiple EAP servers are deployed for high availability. TOFU mechanisms increase the susceptibility to traffic interception attacks and should only be used if there are adequate controls in place to mitigate this risk.




## Key Hierarchy

The key schedule for EDHOC is described in Section 4 of {{RFC9528}}. The Key_Material and Method-Id SHALL be derived from the PRK_exporter using the EDHOC-Exporter interface, see Section 4.2.1 of {{RFC9528}}.

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

The EAP-EDHOC peers and EAP-EDHOC servers MUST comply with the compliance requirements (mandatory-to-implement cipher suites, signature algorithms, key exchange algorithms, extensions, etc.) defined in Section 7 of {{RFC9528}}.



## EAP State Machines

The EAP-EDHOC server sends message_4 in an EAP-Request as a protected success result indication.

EDHOC error messages SHOULD be considered failure result indication, as defined in {{RFC3748}}.
After sending or receiving an EDHOC error message, the EAP-EDHOC server may only send an EAP-Failure. EDHOC error messages are unprotected.

The keying material can be derived after the EDHOC message_2 has
been sent or received. Implementations following {{RFC4137}} can then
set the eapKeyData and aaaEapKeyData variables. 

The keying material can be made available to lower layers and the
authenticator after the protected success indication (message_4) has
been sent or received. Implementations following {{RFC4137}} can set the eapKeyAvailable and aaaEapKeyAvailable variables.



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
     |R R R S M L L L|
     +-+-+-+-+-+-+-+-+

     R = Reserved
     S = EAP-EDHOC start
     M = More fragments
     L = Length of EDHOC Message Length

      Implementations of this specification MUST set the reserved bits to zero and 
      MUST ignore them on reception.

      The S bit (EAP-EDHOC start) is set in an EAP-EDHOC Start message.  This
      differentiates the EAP-EDHOC Start message from a fragment
      acknowledgement.  

      The M bit (more fragments) is set on all but the last fragment.  

      The three L bits is the binary encoding of the size of the EDHOC Message Length, 
      in the range 1 byte to 4 bytes. All three bits set to 0 indicates that the field 
      is not present. If the first two L bits are set to 0, and the final L bit of the 
      flag is set to 1, then the size of the EDHOC Message Length field is 1 byte, and 
      so on.  
  


   EDHOC Message Length

      The EDHOC Message Length field can have a size of one to four octets and is 
      present only if the L bits represent a value greater than 0.  This field provides 
      the total length of the EDHOC message that is being fragmented.

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
     |R R R R M L L L|
     +-+-+-+-+-+-+-+-+

     R = Reserved
     M = More fragments
     L = Length of EDHOC Message Length

      Implementations of this specification MUST set the reserved bits
      to zero and MUST ignore them on reception.

      The M bit (more fragments) is set on all but the last fragment.

      The three L bits are the binary encoding of the size of the EDHOC Message Length, 
      in the range of 1 byte to 4 bytes. All three bits set to 0 indicate that the field 
      is not present. If the first two L bits are set to 0, and the final L bit of the 
      flag is set to 1, then the size of the EDHOC Message Length field is 1 byte, and 
      so on.  
      

   EDHOC Message Length

      The EDHOC Message Length field can be one to four octets and is present only
      if the L bit is set.  This field provides the total length of the
      EDHOC message that is being fragmented.

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


The security considerations of EDHOC {{RFC9528}} apply to this document. The design of EAP-EDHOC follows closely EAP-TLS 1.3 {{RFC9190}} and so its security considerations also apply.

Except for MSK and EMSK, derived keys are not exported.


## Security Claims 

Using EAP-EDHOC provides the security claims of EDHOC, which are described next.

  1. Mutual authentication:
    The initiator and responder authenticate each other through the EDHOC exchange.    

  2. Forward secrecy:
    Only ephemeral Diffie-Hellman methods are supported by EDHOC, which ensures that the compromise of one session key does not also compromise earlier sessions' keys.

  3. Identity protection:
    EDHOC secures the Responder's credential identifier against passive attacks and the Initiator's credential identifier against active attacks. An active attacker can get the credential identifier of the Responder by eavesdropping on the destination address used for transporting message_1 and then sending its message_1 to the same address.
    
  4. Cipher suite negotiation:
    The Initiator's list of supported cipher suites and order of preference is fixed, and the selected cipher suite is the first cipher suite that the Responder supports.

  5. Integrity protection:
    EDHOC integrity protects all message content using transcript hashes for key derivation and as additional authenticated data, including, e.g., method type, ciphersuites, and external authorization data.


--- back


# Acknowledgments
{: numbered="no"}

The authors sincerely thank Eduardo Ingles-Sanchez for his contribution in the initial phase of this work. We also want to thank Francisco Lopez Gomez for his work on the implementation of EAP-EDHOC.

--- fluff
