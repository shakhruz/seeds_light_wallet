import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:seeds/blocs/rates/viewmodels/rates_state.dart';
import 'package:seeds/datasource/local/settings_storage.dart';
import 'package:seeds/datasource/remote/model/member_model.dart';
import 'package:seeds/datasource/remote/model/token_model.dart';
import 'package:seeds/domain-shared/app_constants.dart';
import 'package:seeds/domain-shared/page_state.dart';
import 'package:seeds/domain-shared/shared_use_cases/get_available_balance_use_case.dart';
import 'package:seeds/screens/transfer/send/send_confirmation/interactor/usecases/send_transaction_use_case.dart';
import 'package:seeds/screens/transfer/send/send_enter_data/interactor/mappers/send_amount_change_mapper.dart';
import 'package:seeds/screens/transfer/send/send_enter_data/interactor/mappers/send_enter_data_state_mapper.dart';
import 'package:seeds/screens/transfer/send/send_enter_data/interactor/mappers/send_transaction_mapper.dart';
import 'package:seeds/screens/transfer/send/send_enter_data/interactor/viewmodels/send_enter_data_events.dart';
import 'package:seeds/screens/transfer/send/send_enter_data/interactor/viewmodels/send_enter_data_state.dart';
import 'package:seeds/screens/transfer/send/send_enter_data/interactor/viewmodels/show_send_confirm_dialog_data.dart';

/// --- BLOC
class SendEnterDataPageBloc extends Bloc<SendEnterDataPageEvent, SendEnterDataPageState> {
  SendEnterDataPageBloc({
    required MemberModel member,
    required RatesState rates,
    required TokenModel token,
  }) : super(SendEnterDataPageState.initial(member, rates, token));

  @override
  Stream<SendEnterDataPageState> mapEventToState(SendEnterDataPageEvent event) async* {
    if (event is InitSendDataArguments) {
      yield state.copyWith(pageState: PageState.loading, showSendingAnimation: false);

      final Result result = await GetAvailableBalanceUseCase().run();

      yield SendEnterDataStateMapper().mapResultToState(state, result, state.ratesState, "0");
    } else if (event is OnMemoChange) {
      yield state.copyWith(memo: event.memoChanged);
    } else if (event is OnAmountChange) {
      yield SendAmountChangeMapper().mapResultToState(state, state.ratesState, event.amountChanged);
    } else if (event is OnNextButtonTapped) {
      yield state.copyWith(
        pageState: PageState.success,
        shouldAutoFocusEnterField: false,
        pageCommand: ShowSendConfirmDialog(
          amount: state.quantity.toString(),
          toAccount: state.sendTo.account,
          memo: state.memo,
          toName: state.sendTo.nickname,
          toImage: state.sendTo.image,
          currency: settingsStorage.selectedFiatCurrency,
          fiatAmount: state.fiatAmount,
        ),
      );
    } else if (event is OnSendButtonTapped) {
      yield state.copyWith(pageState: PageState.loading, showSendingAnimation: true);

      final token = state.token;

      final Result result = await SendTransactionUseCase().run(
        actionName: transfer_action,
        account: token.contract,
        data: {
          'from': settingsStorage.accountName,
          'to': state.sendTo.account,
          'quantity': '${state.quantity.toStringAsFixed(token.precision)} ${token.symbol}',
          'memo': state.memo,
        },
      );

      yield SendTransactionMapper().mapResultToState(state, result);
    } else if (event is ClearPageCommand) {
      yield state.copyWith();
    }
  }
}
