---
v: 3
title: Using the Extensible Authentication Protocol (EAP) with Ephemeral Diffie-Hellman over COSE (EDHOC)
docname: draft-ietf-emu-eap-edhoc-latest
abbrev: EAP-EDHOC

v3xml2rfc:
  silence:
  - Found SVG with width or height specified

ipr: trust200902
submissionType: IETF
area: ""
workgroup: "EAP Method Update"
cat: std
consensus: true

coding: utf-8
pi: # can use array (if all yes) or hash here
  toc: yes
  sortrefs: yes
  symrefs: yes
  tocdepth: 3

venue:
  group: "EAP Method Update"
  type: ""
  mail: "emu@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/emu"
  github: "dangarciacarrillo/i-d-eap-edhoc"

author:
- name: Dan Garcia-Carrillo
  org: University of Oviedo
  street: Gijon, Asturias  33203
  country: Spain
  email: garciadan@uniovi.es
- name: Rafael Marin-Lopez
  org: University of Murcia
  street: Murcia  30100
  country: Spain
  email: rafa@um.es
- name: Göran Selander
  org: Ericsson
  street: SE-164 80 Stockholm
  country: Sweden
  email: goran.selander@ericsson.com
- name: John | Preuß Mattsson
  org: Ericsson
  street: SE-164 80 Stockholm
  country: Sweden
  email: john.mattsson@ericsson.com
- name: Francisco Lopez-Gomez
  org: University of Murcia
  street: Murcia  30100
  country: Spain
  email: francisco.lopezg@um.es

normative:

   RFC2119:
   RFC3748:
   RFC7542:
   RFC8174:
   RFC8610:
   RFC9190:
   RFC9528:

informative:

  RFC4137:
  RFC5216:
  RFC6677:
  RFC7252:
  RFC7593:
  RFC8392:
  RFC8446:
  RFC8613:
  RFC8949:
  RFC9052:
  RFC9053:
  RFC9668:
  RFC9360:
  I-D.ietf-lake-edhoc-psk:
  I-D.ietf-cose-cbor-encoded-cert:
  I-D.ietf-lake-app-profiles:
  I-D.ietf-lake-edhoc-impl-cons:
  Sec5G:
    target: https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3169
    title: "Security architecture and procedures for 5G System"
    author:
      -
        ins: 3GPP TS 33.501
    date: March 2025

--- abstract

The Extensible Authentication Protocol (EAP), defined in RFC 3748, provides a standard mechanism for support of multiple authentication methods. This document specifies the EAP authentication method EAP-EDHOC, based on Ephemeral Diffie-Hellman Over COSE (EDHOC). EDHOC is a lightweight security handshake protocol, enabling authentication and establishment of shared secret keys suitable in constrained settings. This document also provides guidance on authentication and authorization for EAP-EDHOC.

--- middle

# Introduction

The Extensible Authentication Protocol (EAP), defined in {{RFC3748}}, provides a standard mechanism for support of multiple authentication methods. This document specifies the EAP authentication method EAP-EDHOC, which is based on the lightweight security handshake protocol Ephemeral Diffie-Hellman Over COSE (EDHOC) {{RFC9528}}.

EAP-EDHOC is similar to EAP-TLS 1.3 {{RFC9190}}, since EDHOC is based on a similar security protocol design as the TLS 1.3 handshake {{RFC8446}}. However, EDHOC has been optimized for highly constrained settings, for example involving wirelessly connected battery powered 'things' with embedded microcontrollers, sensors, and actuators. An overview of EDHOC is given in {{edhoc-overview}}.

 The EAP-EDHOC method enables the integration of EDHOC into different applications and use cases using the EAP framework.

## EDHOC Overview {#edhoc-overview}

Ephemeral Diffie-Hellman Over COSE (EDHOC) is a lightweight authenticated ephemeral key exchange, including mutual authentication and establishment of shared secret keying material, see {{RFC9528}}.

EDHOC provides state-of-the-art security design at very low message overhead, targeting low complexity implementations and allowing extensibility. The security of EDHOC has been thoroughly analyzed, some references are provided in {{Section 9.1 of RFC9528}}.

The main features of EDHOC are:

* Support for different authentication methods and credentials. The authentication methods include (mixed) signatures and static Diffie-Hellman keys {{RFC9528}}, and pre-shared keys {{I-D.ietf-lake-edhoc-psk}}. A large and extensible variety of authentication credentials is supported, including public key certificates such as X.509 and C509 {{I-D.ietf-cose-cbor-encoded-cert}}, CBOR Web Tokens, and CWT Claims Sets {{RFC8392}}.

* A standardized and extensible format for identification of credentials, using COSE header parameters {{RFC9052}}, supporting credential transport by value or by reference, enabling very compact representations.

* Crypto agility and secure cipher suite negotiation, with predefined compactly represented cipher suites and support for extensibility using the COSE algorithms registry {{RFC9053}}.

* Selection of connection identifiers identifying a session for which keys are agreed.

* Support for integration of external security applications into EDHOC by transporting External Authorization Data (EAD) included in and protected as EDHOC messages.

A necessary condition for a successful completion of an EDHOC session is that both peers support a common application profile including method, cipher suite,  etc. More details are provided in  {{I-D.ietf-lake-app-profiles}}.

EDHOC messages make use of lightweight primitives, specifically CBOR {{RFC8949}} and COSE {{RFC9052}} {{RFC9053}} for efficient encoding and security services in constrained devices. EDHOC is optimized for use with CoAP {{RFC7252}} and OSCORE {{RFC8613}} to secure resource access in constrained IoT use cases, but it is not bound to a particular transport or communication security protocol.


# Conventions and Definitions

{::boilerplate bcp14-tagged}

Readers are expected to be familiar with the terms and concepts described in EAP {{RFC3748}} and EDHOC {{RFC9528}}.

# Protocol Overview {#overview}

## Overview of the EAP-EDHOC Conversation

The EAP exchange involves three key entities: the EAP peer, the EAP authenticator, and the EAP server. The EAP authenticator is a network device that enforces access control and initiates the EAP authentication process. The EAP peer is the device seeking network access and communicates directly with the EAP authenticator. The EAP server is responsible for selecting and implementing the authentication methods and for authenticating the EAP peer. When the EAP server is not located on a separate backend authentication server, it is integrated into the EAP authenticator. For simplicity, the operational flow diagrams in this document depict only the EAP peer and the EAP server.

The EDHOC protocol running between an Initiator and a Responder consists of three mandatory messages (message_1, message_2, message_3), an optional message_4, and an error message. In an EDHOC session, EAP-EDHOC uses all messages including message_4, which is mandatory and acts as a protected success indication.

After receiving an EAP-Request packet with EAP-Type=EAP-EDHOC as described in this document, the conversation will continue with the EDHOC messages transported in the data fields of EAP-Response and EAP-Request packets. When EAP-EDHOC is used, the formatting and processing of EDHOC messages SHALL be done as specified in {{RFC9528}}. This document only lists additional and different requirements, restrictions, and processing compared to {{RFC9528}}.

The message processing in {{Section 5 of RFC9528}} states that certain data (EAD items, connection identifiers, application algorithms, etc.) is made available to the application. Since EAP-EDHOC is now acting as the application of EDHOC, it may need to handle this data to complete the protocol execution. See also {{I-D.ietf-lake-edhoc-impl-cons}}.

Resumption of EAP-EDHOC may be defined using the EDHOC-PSK authentication method {{I-D.ietf-lake-edhoc-psk}}.

### Successful EAP-EDHOC Message Flow without Fragmentation

EDHOC allows EAP-EDHOC to support authentication credentials of any type defined by COSE, which can be either transported or referenced during the protocol.

The optimization combining the execution of EDHOC with the first subsequent OSCORE transaction specified in {{RFC9668}} is not supported in this EAP method.

{{message-flow}} shows an example message flow for a successful execution of EAP-EDHOC.

~~~~~~~~~~~~~~~~~~~~~~~aasvg
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                                                       |
    |                                EAP-Request/Identity   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity                               |
    |   (Privacy-Friendly)                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC Start)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_2)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_3)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_4)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Success   |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message-flow title="EAP-EDHOC Message Flow" artwork-align="center"}

If the EAP-EDHOC peer authenticates successfully, the EAP-EDHOC server MUST send an EAP-Request packet with EAP-Type=EAP-EDHOC containing message_4 as a protected success indication.

If the EAP-EDHOC server authenticates successfully, and the EAP-EDHOC peer achieves key confirmation by successfully verifying EDHOC message_4, then the EAP-EDHOC peer MUST send an EAP-Response message with EAP-Type=EAP-EDHOC containing no data. Finally, the EAP-EDHOC server sends an EAP-Success.

Note that the Identity request is optional {{RFC3748}} and might not be used in systems like 3GPP 5G {{Sec5G}} where the identity is transferred encrypted by other means before the EAP exchange. While the EAP-Response/EAP-Type=EAP-EDHOC and EAP-Success are mandatory {{RFC3748}} they do not contain any information and might be encoded into other system specific messages {{Sec5G}}.

### Transport and Message Correlation

EDHOC is not bound to a particular transport layer and can even be used in environments without IP. Nonetheless, {{RFC9528}} provides a set of requirements for a transport protocol to use with EDHOC. These include: handling the loss, reordering, duplication, correlation, and fragmentation of messages; demultiplexing EDHOC messages from other types of messages; and denial-of-service protection. All these requirements are fulfilled by the EAP protocol, EAP method, or EAP lower layer, as specified in {{RFC3748}}.

For message loss, this can be either fulfilled by the EAP layer, or the EAP lower layer, or both.

For reordering, EAP relies on the EAP lower layer ordering guarantees, for correct operation.

For duplication and message correlation, EAP has the Identifier field, which allows both the EAP peer and EAP authenticator to detect duplicates and match a request with a response.

Fragmentation is defined by this EAP method, see {{fragmentation}}. The EAP framework {{RFC3748}}, specifies that EAP methods need to provide fragmentation and reassembly if EAP packets can exceed the minimum MTU of 1020 octets.

To demultiplex EDHOC messages from other types of messages, EAP provides the Type field.

This method does not provide other mitigation against denial-of-service than EAP {{RFC3748}}.

### Termination

{{message1-reject}}, {{message2-reject}}, {{message3-reject}}, and {{message4-reject}} illustrate message flows in several cases where the EAP-EDHOC peer or EAP-EDHOC server sends an EDHOC error message.

{{message1-reject}} shows an example message flow where the EAP-EDHOC server rejects message_1 with an EDHOC error message.

~~~~~~~~~~~~~~~~~~~~~~~aasvg
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                                                       |
    |                                EAP-Request/Identity   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity                               |
    |   (Privacy-Friendly)                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC Start)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC error)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Failure   |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message1-reject title="EAP-EDHOC Server Rejection of message_1" artwork-align="center"}

{{message2-reject}} shows an example message flow where the EAP-EDHOC server authentication is unsuccessful and the EAP-EDHOC peer sends an EDHOC error message.

~~~~~~~~~~~~~~~~~~~~~~~aasvg
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                                                       |
    |                                EAP-Request/Identity   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity                               |
    |   (Privacy-Friendly)                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC Start)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_2)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC error)                                       |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Failure   |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message2-reject title="EAP-EDHOC Peer Rejection of message_2" artwork-align="center"}

{{message3-reject}} shows an example message flow where the EAP-EDHOC server authenticates to the EAP-EDHOC peer successfully, but the EAP-EDHOC peer fails to authenticate to the EAP-EDHOC server, and the server sends an EDHOC error message.

Note that the EDHOC error message cannot be omitted. For example, with EDHOC ERR_CODE 3 "Unknown credential referenced", it is indicated that the EDHOC peer should, for the next EDHOC session, try another credential identifier supported according to the application profile.

~~~~~~~~~~~~~~~~~~~~~~~aasvg
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                                                       |
    |                                EAP-Request/Identity   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity                               |
    |   (Privacy-Friendly)                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC Start)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_2)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_3)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC error)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Failure   |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message3-reject title="EAP-EDHOC Server Rejection of message_3" artwork-align="center"}

{{message4-reject}} shows an example message flow where the EAP-EDHOC server sends the EDHOC message_4 to the EAP peer, but the protected success indication fails, and the peer sends an EDHOC error message.

~~~~~~~~~~~~~~~~~~~~~~~aasvg
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                                                       |
    |                                EAP-Request/Identity   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity                               |
    |   (Privacy-Friendly)                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                       (EDHOC Start)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_2)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_3)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_4)   |
    | <---------------------------------------------------  |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC error)                                       |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Failure   |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #message4-reject title="EAP-EDHOC Peer Rejection of message_4" artwork-align="center"}


### Identity

It is RECOMMENDED to use anonymous Network Access Identifiers (NAIs) {{RFC7542}} in the Identity Response, as such identities are routable and privacy-friendly.

While opaque blobs are allowed by {{RFC3748}}, such identities are NOT RECOMMENDED as they are not routable and should only be considered in local deployments where the EAP-EDHOC peer, EAP authenticator, and EAP-EDHOC server all belong to the same network.

Many client certificates contain an identity such as an email address, which is already in NAI format. When the certificate contains an NAI as subject name or alternative subject name, an anonymous NAI SHOULD be derived from the NAI in the certificate. See {{privacy}}.

### Privacy

EAP-EDHOC peer and server implementations supporting EAP-EDHOC MUST support anonymous NAIs (Section 2.4 of {{RFC7542}}).
A node supporting EAP-EDHOC MUST NOT send its username (or any other permanent identifiers) in cleartext in the Identity Response (or any message used instead of the Identity Response). Following {{RFC7542}}, it is RECOMMENDED to omit the username (i.e., the NAI is @realm), but other constructions such as a fixed username (e.g., anonymous@realm) or an encrypted username (e.g., xCZINCPTK5+7y81CrSYbPg+RKPE3OTrYLn4AQc4AC2U=@realm) are allowed. Note that the NAI MUST be a UTF-8 string as defined by the grammar in Section 2.2 of {{RFC7542}}.

### Fragmentation {#fragmentation}

EDHOC is designed to perform well in constrained networks where message sizes are restricted for performance reasons. When credentials are transferred by reference, EAP-EDHOC messages are typically so small that fragmentation is not needed. However, as EAP-EDHOC also supports large X.509 certificate chains, EAP-EDHOC implementations MUST provide support for fragmentation and reassembly. Since EAP is a lock-step protocol, fragmentation support can be easily added.

To do so, the EAP-Response and EAP-Request packets of EAP-EDHOC have a set of information fields that allow for the specification of the fragmentation process (see {{detailed-description}} for the detailed description). As a summary, EAP-EDHOC fragmentation support is provided through the addition of flag bits (M and L) within the EAP-Response and EAP-Request packets, as well as a (conditional) EAP-EDHOC Message Length field that can be zero to four octets.

If the L bits are set, this indicates that the message is fragmented, and that the total message length is specified in the EAP-EDHOC Message Length field.

Implementations MUST NOT set the L bit in unfragmented messages. However, they MUST accept unfragmented messages regardless of whether the L bit is set. Some EAP implementations and access networks impose limits on the number of EAP packet exchanges that can be processed. To minimize fragmentation, it is RECOMMENDED to use compact EAP-EDHOC peer, EAP-EDHOC server, and trust anchor authentication credentials, as well as to limit the length of certificate chains. Additionally, mechanisms that reduce the size of Certificate messages are RECOMMENDED.

To be more specific, the L field indicates the length of the EDHOC Message Length field, which MUST be present for the first fragment of a fragmented EDHOC message. The M flag bit is set on all but the last fragment. The S flag bit is set only within the EAP-EDHOC start message sent by the EAP server to the peer (and is also used in unfragmented exchanges). The EDHOC Message Length field provides the total length of the EDHOC message that is being fragmented; this simplifies buffer allocation.

When an EAP-EDHOC peer receives an EAP-Request packet with the M bit set, it MUST respond with an EAP-Response with EAP-Type=EAP-EDHOC and no data. This serves as a fragment ACK. The EAP server MUST wait until it receives the EAP-Response before sending another fragment. To prevent errors in the processing of fragments, the EAP server MUST increment the Identifier field for each fragment contained within an EAP-Request, and the peer MUST include this Identifier value in the fragment ACK contained within the EAP-Response. Retransmitted fragments will contain the same Identifier value.

Similarly, when the EAP-EDHOC server receives an EAP-Response with the M bit set, it MUST respond with an EAP-Request with EAP-Type=EAP-EDHOC and no data. This serves as a fragment ACK. The EAP peer MUST wait until it receives the EAP-Request before sending another fragment. To prevent errors in the processing of fragments, the EAP server MUST increment the Identifier value for each fragment ACK contained within an EAP-Request, and the peer MUST include this Identifier value in the subsequent fragment contained within an EAP-Response.

{{fragmentation-flow}} illustrates the conversation beetween the endpoints in the case where the EAP-EDHOC mutual authentication is successful and fragmentation is required:

~~~~~~~~~~~~~~~~~~~~~~~aasvg
EAP-EDHOC Peer                                   EAP-EDHOC Server

    |                                                       |
    |                                EAP-Request/Identity   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/Identity                               |
    |   (Privacy-Friendly)                                  |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                            (EDHOC Start, S bit set)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_1)                                   |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |     (EDHOC message_2, Fragment 1, L and M bits set)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |            (EDHOC message_2, Fragment 2, M bit set)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                       (EDHOC message_2, Fragment 3)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_3, Fragment 1, L and M bits set)     |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_3, Fragment 2, M bit set)            |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    |   (EDHOC message_3, Fragment 3)                       |
    | ----------------------------------------------------> |
    |                                                       |
    |                      EAP-Request/EAP-Type=EAP-EDHOC   |
    |                                   (EDHOC message_4)   |
    | <---------------------------------------------------- |
    |                                                       |
    |   EAP-Response/EAP-Type=EAP-EDHOC                     |
    | ----------------------------------------------------> |
    |                                                       |
    |                                         EAP-Success   |
    | <---------------------------------------------------- |
    |                                                       |
~~~~~~~~~~~~~~~~~~~~~~~
{: #fragmentation-flow title="EAP-EDHOC Fragmentation Example" artwork-align="center"}

## Identity Verification {#identity-verification}

The EAP peer identity provided in the EAP-Response/Identity is not authenticated by EAP-EDHOC. Unauthenticated information MUST NOT be used for accounting purposes or to give authorization. The EAP authenticator and the EAP server MAY examine the identity presented in EAP-Response/Identity for purposes such as routing and EAP method selection. EAP-EDHOC servers MAY reject conversations if the identity does not match their policy.

The EAP server identity in the EDHOC server certificate is typically a fully qualified domain name (FQDN) in the SubjectAltName (SAN) extension. Since EAP-EDHOC deployments may use more than one EAP server, each with a different certificate, EAP peer implementations SHOULD allow for the configuration of one or more trusted root certificates (CA certificate) to authenticate the server certificate and one or more server names to match against the SubjectAltName (SAN) extension in the server certificate. If any of the configured names match any of the names in the SAN extension, then the name check passes. To simplify name matching, an EAP-EDHOC deployment can assign a designated name to represent an authorized EAP server. This name can then be included in the SANs list of each certificate used by this EAP-EDHOC server. If server name matching is not used, the EAP peer has reduced assurance that the EAP server it is interacting with is authoritative for the given network. If name matching is not used with a public root CA, then effectively any server can obtain a certificate that will be trusted for EAP authentication by the peer.

The process of configuring a root CA certificate and a server name is non-trivial; therefore, automated methods of provisioning are RECOMMENDED. For example, the eduroam federation {{RFC7593}} provides a Configuration Assistant Tool (CAT) to automate the configuration process. In the absence of a trusted root CA certificate (user-configured or system-wide), EAP peers MAY implement a Trust On First Use (TOFU) mechanism where the peer trusts and stores the server certificate during the first connection attempt. The EAP peer ensures that the server presents the same stored certificate on subsequent interactions. The use of a TOFU mechanism does not allow for the server certificate to change without out-of-band validation of the certificate and is therefore not suitable for many deployments including ones where multiple EAP servers are deployed for high availability. TOFU mechanisms increase the susceptibility to traffic interception attacks and should only be used if there are adequate controls in place to mitigate this risk.

## Key Hierarchy {#Key_Hierarchy}

The key derivation for EDHOC is described in Section 4 of {{RFC9528}}. The key material and Method-Id SHALL be derived from the PRK_exporter using the EDHOC_Exporter interface, see Section 4.2.1 of {{RFC9528}}.

Type is the value of the EAP Type field defined in Section 2 of {{RFC3748}}. For EAP-EDHOC, Type has the value TBD1. The << >> notation defined in Section G.3 of {{RFC8610}} means that the CBOR-encoded integer Type value is embedded in a CBOR byte string. The use of Type as context enables the reuse of exporter labels across other future EAP methods based on EDHOC.

~~~~~~~~~~~~~~~~~~~~~~~
Type        =  TBD1
MSK         =  EDHOC_Exporter(TBD2, << Type >>, 64)
EMSK        =  EDHOC_Exporter(TBD3, << Type >>, 64)
Method-Id   =  EDHOC_Exporter(TBD4, << Type >>, 64)
Session-Id  =  Type || Method-Id
Peer-Id     =  ID_CRED_I
Server-Id   =  ID_CRED_R
~~~~~~~~~~~~~~~~~~~~~~~

EAP-EDHOC exports the MSK and the EMSK and does not specify how it is used by lower layers.

## Parameter Negotiation and Compliance Requirements

The EAP-EDHOC peers and EAP-EDHOC servers MUST comply with the requirements defined in Section 8 of {{RFC9528}}, including mandatory-to-implement cipher suites, signature algorithms, key exchange algorithms, and extensions.

## EAP State Machines

The EAP-EDHOC server sends message_4 in an EAP-Request as a protected success result indication.

EDHOC error messages SHOULD be considered failure result indication, as defined in {{RFC3748}}. After sending or receiving an EDHOC error message, the EAP-EDHOC server may only send an EAP-Failure. EDHOC error messages are unprotected.

The keying material can be derived by the Initiator upon receiving EDHOC message_2, and by the Responder upon receiving EDHOC message_3. Implementations following {{RFC4137}} can then set the eapKeyData and aaaEapKeyData variables.

The keying material can be made available to lower layers and the EAP authenticator after the protected success indication (message_4) has been sent or received. Implementations following {{RFC4137}} can set the eapKeyAvailable and aaaEapKeyAvailable variables.

## EAP Channel Binding {#Channel_Binding}

EAP-EDHOC allows the secure exchange of information between the endpoints of the authentication process (i.e., the EAP peer and the EAP server) using protected data fields. These fields can be used to exchange EAP channel binding information, as defined in {{RFC6677}}.

Section 6 in {{RFC6677}} outlines requirements for components implementing channel binding information, all of which are satisfied by EAP-EDHOC, including confidentiality and integrity protection. Additionally, EAP-EDHOC supports fragmentation, allowing the inclusion of additional information at the method level without issues.

While the EAD_1 and EAD_2 fields (transmitted in EDHOC message_1 and EDHOC message_2, respectively) are integrity protected through the transcript hash, the channel binding protocol defined in {{RFC6677}} must be transported after keying material has been derived between the endpoints in the EAP communication and before the peer is exposed to potential adverse effects from joining an adversarial network. Therefore, compliance with {{RFC6677}} requires use of the EAD_3 and EAD_4 fields, transmitted in EDHOC message_3 and EDHOC message_4, respectively.

If the server detects a consistency error in the channel binding information contained in EAD_3, it will send a protected indication of failed consistency in EAD_4. Subsequently, the EAP peer will respond with the standard empty EAP-EDHOC message and the EAP server will conclude the exchange with an EAP-Failure message.

Accordingly, this document specifies a new EAD item, with ead_label = TBD5, to incorporate EAP channel binding information into the EAD fields of the EAP-EDHOC messages. See {{iana-ead}}.

# Detailed Description of the EAP-EDHOC Request and Response Protocol {#detailed-description}

The EAP-EDHOC packet format for Requests and Responses is summarized in {{packet}}. Fields are transmitted from left to right. following a structure inspired by the EAP-TLS packet format {{RFC5216}}. As specified in Section 4.1 of {{RFC3748}}, EAP Request and Response packets consist of Code, Identifier, Length, Type, and Type-Data fields. The functions of the Code, Identifier, Length, and Type fields are reiterated here for convenience. The EAP Type-Data field consists of the R, S, M, L, EDHOC Message Length, and EDHOC Data fields.

~~~~~~~~~~~~~~~~~~~~~~~
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     Code      |   Identifier  |            Length             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     Type      |  R  |S|M|  L  |      EDHOC Message Length     ~
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                          EDHOC Data                           ~
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
~~~~~~~~~~~~~~~~~~~~~~~
{: #packet title="EAP-EDHOC Request and Response Packet Format" artwork-align="center"}

## EAP-EDHOC Request Packet

Code:
: 1 (Request)

Identifier:
: The Identifier field is one octet and aids in matching responses with requests. The Identifier field MUST be changed on each new (non-retransmission) Request packet, and MUST be the same if a Request packet is retransmitted due to a timeout while waiting for a Response.

Length:
: The Length field is two octets and indicates the length of the EAP packet including the Code, Identifier, Length, Type, and Data fields. Octets outside the range of the Length field should be treated as Data Link Layer padding and MUST be ignored on reception.

Type:
: TBD1 (EAP-EDHOC)

R:
: Implementations of this specification MUST set the R bits (reserved) to zero and MUST ignore them on reception.

S:
: The S bit (EAP-EDHOC start) is set in an EAP-EDHOC Start message. This differentiates the EAP-EDHOC Start message from a fragment acknowledgement.

M:
: The M bit (more fragments) is set on all but the last fragment. I.e., when there is no fragmentation, it is set to zero.

L:
: The L field is the binary encoding of the size of the EDHOC Message Length, in the range 0 byte to 4 bytes. All three bits set to 0 indicates that the EDHOC Message Length field is not present. If the first two bits of the L field are set to 0 and the final bit is set to 1, then the size of the EDHOC Message Length field is 1 byte, and so on.

EDHOC Message Length:
: The EDHOC Message Length field can have a size of one to four octets and is present only if the L field represent a value greater than 0. This field provides the total length of the EDHOC message that is being fragmented. When there is no fragmentation, it is not present.

EDHOC Data:
: The EDHOC data consists of the whole or a fragment of the transported EDHOC message.

## EAP-EDHOC Response Packet

Code:
: 2 (Response)

Identifier:
: The Identifier field is one octet and MUST match the Identifier field from the corresponding request.

Length:
: The Length field is two octets and indicates the length of the EAP packet including the Code, Identifier, Length, Type, and Data fields. Octets outside the range of the Length field should be treated as Data Link Layer padding and MUST be ignored on reception.

Type:
: TBD1 (EAP-EDHOC)

R:
: Implementations of this specification MUST set the R bits (reserved) to zero and MUST ignore them on reception.


S:
: The S bit (EAP-EDHOC start) is set to zero.

M:
: The M bit (more fragments) is set on all but the last fragment. I.e., when there is no fragmentation, it is set to zero.

L:
: The L field is the binary encoding of the size of the EDHOC Message Length, in the range 0 byte to 4 bytes. All three bits set to 0 indicates that the EDHOC Message Length field is not present. If the first two bits of the L field are set to 0 and the final bit is set to 1, then the size of the EDHOC Message Length field is 1 byte, and so on.

EDHOC Message Length:
: The EDHOC Message Length field can have a size of one to four octets and is  present only if the L bits represent a value greater than 0.  This field provides the total length of the EDHOC message that is being fragmented. When there is no fragmentation, it is not present.

EDHOC Data:
: The EDHOC data consists of the whole or a fragment of the transported EDHOC message.

# IANA Considerations {#iana}

## EAP Type

IANA has registered the following new type in the "Method Types" registry under the group name "Extensible Authentication Protocol (EAP) Registry":

~~~~~~~~~~~~~~~~~~~~~~~
Value: TBD1
Description: EAP-EDHOC
~~~~~~~~~~~~~~~~~~~~~~~

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

## EDHOC External Authorization Data Registry {#iana-ead}

IANA has registered the following new label in the "EDHOC External Authorization Data" registry under the group name "Ephemeral Diffie-Hellman Over COSE (EDHOC)":

~~~~~~~~~~~~~~~~~~~~~~~
Label: TBD5
Description: EAP channel binding information
~~~~~~~~~~~~~~~~~~~~~~~

This new EAD item is intended only for EAD_3 and EAD_4. Then, it MUST be ignored if included in other EAD fields. This new EAD item is considered as non-critical. 
Multiple occurrences of this new EAD item in one EAD field are allowed.

# Security Considerations {#security}

The security considerations of EAP {{RFC3748}} and EDHOC {{RFC9528}} apply to this document. Since the design of EAP-EDHOC closely follows EAP-TLS 1.3 {{RFC9190}}, many of its security considerations are also relevant.


## Security Claims

### EAP Security Claims

EAP security claims are defined in Section 7.2.1 of {{RFC3748}}.
EAP-EDHOC security claims are described next and summarized in {{sec-claims}}.

| Claim                        | |
|Auth. principle:              | Certificates, CWTs, and all credential types for which COSE header parameters are defined (1) |
|Cipher suite negotiation:     | Yes (2)|
|Mutual authentication:        | Yes (3)|
|Integrity protection:         | Yes (4)|
|Replay protection:            | Yes (5)|
|Confidentiality:              | Yes (6)|
|Key derivation:               | Yes (7)|
|Key strength:                 | The specified cipher suites provide key strength of at least 128 bits.|
|Dictionary attack protection: | Yes (8)|
|Fast reconnect:               | No |
|Crypt. binding:               | N/A  |
|Session independence:         | Yes (9)|
|Fragmentation:                | Yes ({{fragmentation}})|
|Channel binding:              | Yes ({{Channel_Binding}}: EAD_3 and EAD_4 can be used to convey integrity-protected channel properties, such as network SSID or peer MAC address.)|
{: #sec-claims title="EAP-EDHOC security claims"}


- (1) Authentication principle:
  EAP-EDHOC establishes a shared secret based on an authenticated ECDH key exchange. The key exchange is authenticated using different kinds of credentials. EAP-EDHOC supports EDHOC credential types. EDHOC supports all credential types for which COSE header parameters are defined. These include X.509 certificates {{RFC9360}}, C509 certificates, CWTs ({{RFC9528}} Section 3.5.3.1), and CCSs ({{RFC8392}} Section 3.5.3.1).

- (2) Cipher suite negotiation:
  The Initiator's list of supported cipher suites and order of preference is fixed, and the selected cipher suite is the cipher suite that is most preferred by the Initiator and that is supported by both the Initiator and the Responder. EDHOC supports all signature algorithms defined by COSE.

- (3) Mutual authentication:
  The initiator and responder authenticate each other through the EDHOC exchange.

- (4) Integrity protection:
  EDHOC integrity protects all message content using transcript hashes for key derivation and as additional authenticated data, including, e.g., method type, cipher suites, and external authorization data.

- (5) Replay protection. EDHOC broadens the message authentication coverage to include  algorithms, external authorization data, and prior plaintext messages, as well as adding an explicit method type. By doing this, an attacker cannot replay or inject messages from a different EDHOC session.

- (6) Confidentiality. EDHOC message_2 provides confidentiality against passive attackers, while message_3 and message_4 provide confidentiality against active attackers.

- (7) Key derivation. Except for MSK and EMSK, derived keys are not exported. Key derivation is discussed in {{Key_Hierarchy}}.

- (8) Dictionary attack protection. EAP-EDHOC provides Dictionary attack protection.

- (9) Session independence. EDHOC generates computationally independent keys derived from the ECDH shared secret.


### Additional Security Claims

- (10) Cryptographic strength and Forward secrecy:
  Only ephemeral key exchange methods are supported by EDHOC, which ensures that the compromise of a session key does not also compromise earlier sessions' keys.

- (11) Identity protection:
  EDHOC secures the Responder's credential identifier against passive attacks and the Initiator's credential identifier against active attacks. An active attacker can get the credential identifier of the Responder by eavesdropping on the destination address used for transporting message_1 and then sending their own message_1.

## Peer and Server Identities
The Peer-Id represents the identity to be used for access control and accounting purposes. The Server-Id represents the identity of the EAP server. The Peer-Id and Server-Id are determined from the information provided in the credentials used.

ID_CRED_I and ID_CRED_R are used to identify the credentials of the Initiator (EAP peer) and Responder (EAP server). Therefore, for Server-Id the ID_CRED_R is used, and for Peer-Id the ID_CRED_I is used.


## Certificate Validation
Same considerations as in EAP-TLS 1.3 Section 5.3 {{RFC9190}} apply here in relation to the use of certificates.

When other types of credentials are used such as CWT/CCS, the application needs to have a clear trust-establishment mechanism and identify the pertinent trust anchors {{RFC9528}}.


## Certificate Revocation
Same considerations as in EAP-TLS 1.3 Section 5.4 {{RFC9190}} apply here in relation to certificates.

When other types of credentials are used such as CWT/CCS, the endpoints are in charge of handling revocation and confirming the validity and integrity of CWT/CCS {{RFC9528}}.


## Packet Modification Attacks
EAP-EDHOC relies on EDHOC, which is designed to encrypt and integrity protect as much information as possible. Any change in any message is detected by means of the transcript hashes integrity verification.

## Authorization
Following the considerations of EDHOC in appendix D.5 Unauthenticated Operation {{RFC9528}}, EDHOC can be used without authentication by allowing the Initiator or Responder to communicate with any identity except its own.

When peer authentication is not used, EAP-EDHOC server implementations MUST take care to limit network access appropriately for authenticated peers. Authorization and accounting MUST be based on authenticated information such as information in the certificate. The requirements for Network Access Identifiers (NAIs) specified in Section 4 of {{RFC7542}} apply and MUST be followed.


## Privacy Considerations
Considerations in Section 9.6 of {{RFC9528}} against tracking of users and eavesdropping on Identity Responses or certificates apply here. Also, the considerations of Section 5.8 of {{RFC9190}} regarding anonymous NAIs also applies.


## Pervasive Monitoring
Considerations in  Section 9.1 of {{RFC9528}} about pervasive monitoring apply here.

## Cross-Protocol Attacks
This applies in the context of TLS 1.3 resumption, while it does not apply here.

--- back

# Acknowledgments
{: numbered="no"}

The authors sincerely thank Eduardo Ingles-Sanchez for his contribution in the initial phase of this work. We also want to thank Marco Tiloca for his review.

This work was supported partially by grant PID2020-112675RB-C44 funded by MCIN/AEI/10.13039/5011000011033 (ONOFRE3-UMU).

This work was supported partially by Vinnova - the Swedish Agency for Innovation Systems - through the EUREKA CELTIC-NEXT project CYPRESS.

--- fluff
