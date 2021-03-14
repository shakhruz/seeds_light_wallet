import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:seeds/v2/domain-shared/page_state.dart';
import 'package:seeds/v2/screens/send_scanner/interactor/viewmodels/ScanQrCodeResultData.dart';

class SendPageState extends Equatable {
  final PageState pageState;
  final String error;
  final PageCommand pageCommand;

  const SendPageState({@required this.pageState, this.error, this.pageCommand});

  @override
  List<Object> get props => [pageState];

  SendPageState copyWith({PageState pageState, String error, PageCommand pageCommand}) {
    return SendPageState(
        pageState: pageState ?? this.pageState,
        error: error ?? this.error,
        pageCommand: pageCommand ?? this.pageCommand);
  }

  factory SendPageState.initial() {
    return const SendPageState(pageState: PageState.initial);
  }
}

class PageCommand {}

class NavigateToCustomTransaction extends PageCommand {
  final ScanQrCodeResultData resultData;

  NavigateToCustomTransaction(this.resultData);
}
