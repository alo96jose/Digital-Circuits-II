/* Generated by Yosys 0.40+33 (git sha1 c3ae33da3, clang++ 14.0.0-1ubuntu1.1 -fPIC -Os) */

(* top =  1  *)
(* src = "arbiter.v:1.1-28.10" *)
module arbiter(clock, reset, req_0, req_1, gnt_0, gnt_1);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  (* src = "arbiter.v:10.7-10.12" *)
  input clock;
  wire clock;
  (* src = "arbiter.v:11.8-11.13" *)
  output gnt_0;
  wire gnt_0;
  (* src = "arbiter.v:11.15-11.20" *)
  output gnt_1;
  wire gnt_1;
  (* src = "arbiter.v:10.21-10.26" *)
  input req_0;
  wire req_0;
  (* src = "arbiter.v:10.28-10.33" *)
  input req_1;
  wire req_1;
  (* src = "arbiter.v:10.14-10.19" *)
  input reset;
  wire reset;
  NOT _08_ (
    .A(gnt_0),
    .Y(_06_)
  );
  NOR _09_ (
    .A(req_1),
    .B(_06_),
    .Y(_07_)
  );
  NOR _10_ (
    .A(req_0),
    .B(_07_),
    .Y(_02_)
  );
  NOR _11_ (
    .A(reset),
    .B(_02_),
    .Y(_00_)
  );
  NOR _12_ (
    .A(gnt_1),
    .B(req_1),
    .Y(_03_)
  );
  NOR _13_ (
    .A(reset),
    .B(_03_),
    .Y(_04_)
  );
  NOT _14_ (
    .A(_04_),
    .Y(_05_)
  );
  NOR _15_ (
    .A(req_0),
    .B(_05_),
    .Y(_01_)
  );
  (* src = "arbiter.v:16.1-26.4" *)
  DFF _16_ (
    .C(clock),
    .D(_00_),
    .Q(gnt_0)
  );
  (* src = "arbiter.v:16.1-26.4" *)
  DFF _17_ (
    .C(clock),
    .D(_01_),
    .Q(gnt_1)
  );
endmodule
