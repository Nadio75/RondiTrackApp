// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/contribution_cycle_response.dart';
import '../models/create_contribution_cycle_request.dart';

part 'contribution_cycles_client.g.dart';

@RestApi()
abstract class ContributionCyclesClient {
  factory ContributionCyclesClient(Dio dio, {String? baseUrl}) = _ContributionCyclesClient;

  /// List a stokvel's contribution cycles.
  ///
  /// Returns every contribution cycle that belongs to the given stokvel, in the order they were.  ///
  /// created. Cycles of other stokvels are never included.  ///
  ///  ///
  /// **Guarantees:** a `200` always contains only this stokvel's cycles. It is an empty array if the.  ///
  /// stokvel has no cycles yet.  ///
  ///  ///
  /// **Does not:** support paging, filtering or sorting, and does not include the contributions.  ///
  /// recorded against each cycle.  ///
  ///  ///
  /// **Errors:** `400` if `stokvelId` is not a valid GUID; `404` if no stokvel has that id.  ///
  ///  ///
  /// **Example response (200):**.  ///
  ///  ///
  ///     [.  ///
  ///       {.  ///
  ///         "id": "b7e4a2d1-6c3f-4e58-9b20-5d1a0c9e8f77",.  ///
  ///         "stokvelId": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.  ///
  ///         "period": "2026-09",.  ///
  ///         "targetAmount": 1000,.  ///
  ///         "createdAt": "2026-09-01T08:00:00Z".  ///
  ///       }.  ///
  ///     ].
  @GET('/api/v1/stokvels/{stokvelId}/cycles')
  Future<List<ContributionCycleResponse>> getApiV1StokvelsStokvelIdCycles({
    @Path('stokvelId') required String stokvelId,
  });

  /// Create a contribution cycle for a stokvel.
  ///
  /// Creates a new contribution cycle (one month) for the stokvel in the URL. The server generates the.  ///
  /// `id` and `createdAt`. The stokvel comes from the URL, not the body.  ///
  ///  ///
  /// **Rules:** `period` is required and must be in the format `YYYY-MM` (for example `2026-09`; the.  ///
  /// month must be `01` to `12`). `targetAmount` must be greater than zero. A stokvel can have only.  ///
  /// one cycle per period.  ///
  ///  ///
  /// **Checks, in this order:** the body is valid, the stokvel exists, the stokvel does not already.  ///
  /// have a cycle for this period.  ///
  ///  ///
  /// **Guarantees:** on `201`, the cycle exists and a `Location` header points to it.  ///
  /// (`GET /api/stokvels/{stokvelId}/cycles/{cycleId}`).  ///
  ///  ///
  /// **Does not:** check that `targetAmount` matches the stokvel's contribution amount, or that the.  ///
  /// period is current or in the future. Past periods are accepted.  ///
  ///  ///
  /// **Errors:** `400` if `stokvelId` is not a valid GUID, a rule above is broken, or the body is.  ///
  /// missing or is not valid JSON; `404` if no stokvel has that id; `409` if the stokvel already has.  ///
  /// a cycle for this period.  ///
  ///  ///
  /// **Example request:**.  ///
  ///  ///
  ///     { "period": "2026-09", "targetAmount": 1000 }.  ///
  ///  ///
  /// **Example response (201):**.  ///
  ///  ///
  ///     {.  ///
  ///       "id": "b7e4a2d1-6c3f-4e58-9b20-5d1a0c9e8f77",.  ///
  ///       "stokvelId": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.  ///
  ///       "period": "2026-09",.  ///
  ///       "targetAmount": 1000,.  ///
  ///       "createdAt": "2026-09-01T08:00:00Z".  ///
  ///     }.
  @POST('/api/v1/stokvels/{stokvelId}/cycles')
  Future<ContributionCycleResponse> postApiV1StokvelsStokvelIdCycles({
    @Path('stokvelId') required String stokvelId,
    @Body() required CreateContributionCycleRequest body,
  });

  /// Get one contribution cycle by id.
  ///
  /// Returns the contribution cycle with the given id, as long as it belongs to the stokvel in the URL.  ///
  ///  ///
  /// **Guarantees:** a `200` always contains the full cycle. A cycle id that exists but belongs to a.  ///
  /// different stokvel gives `404`, the same as an id that does not exist at all.  ///
  ///  ///
  /// **Errors:** `400` if `stokvelId` or `cycleId` is not a valid GUID; `404` if the cycle does not.  ///
  /// exist or does not belong to this stokvel. The stokvel itself is not looked up, so a stokvel id.  ///
  /// that does not exist also gives `404`, but with the cycle message.  ///
  ///  ///
  /// **Example response (200):**.  ///
  ///  ///
  ///     {.  ///
  ///       "id": "b7e4a2d1-6c3f-4e58-9b20-5d1a0c9e8f77",.  ///
  ///       "stokvelId": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.  ///
  ///       "period": "2026-09",.  ///
  ///       "targetAmount": 1000,.  ///
  ///       "createdAt": "2026-09-01T08:00:00Z".  ///
  ///     }.
  @GET('/api/v1/stokvels/{stokvelId}/cycles/{cycleId}')
  Future<ContributionCycleResponse> getApiV1StokvelsStokvelIdCyclesCycleId({
    @Path('stokvelId') required String stokvelId,
    @Path('cycleId') required String cycleId,
  });

  /// Replace a contribution cycle's period and target amount.
  ///
  /// Replaces **both** fields of an existing cycle. This is a full update, not a partial one: send.  ///
  /// `period` and `targetAmount` every time. The `id`, `stokvelId` and `createdAt` are not changed.  ///
  ///  ///
  /// **Rules:** the same as creating a cycle.  ///
  ///  ///
  /// **Does not:** check for a duplicate period. Unlike creating a cycle, updating a cycle to a.  ///
  /// period that another cycle of the same stokvel already uses is accepted, and the stokvel then.  ///
  /// has two cycles for that period. It also does not change contributions already recorded.  ///
  /// against the cycle.  ///
  ///  ///
  /// **Errors:** `400` if `stokvelId` or `cycleId` is not a valid GUID or a rule is broken (checked.  ///
  /// before the lookup, so an invalid body for an unknown cycle gives `400`, not `404`); `404` if the.  ///
  /// cycle does not exist or does not belong to this stokvel.  ///
  ///  ///
  /// **Example request:**.  ///
  ///  ///
  ///     { "period": "2026-10", "targetAmount": 1200 }.  ///
  ///  ///
  /// **Example response (200):**.  ///
  ///  ///
  ///     {.  ///
  ///       "id": "b7e4a2d1-6c3f-4e58-9b20-5d1a0c9e8f77",.  ///
  ///       "stokvelId": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.  ///
  ///       "period": "2026-10",.  ///
  ///       "targetAmount": 1200,.  ///
  ///       "createdAt": "2026-09-01T08:00:00Z".  ///
  ///     }.
  @PUT('/api/v1/stokvels/{stokvelId}/cycles/{cycleId}')
  Future<ContributionCycleResponse> putApiV1StokvelsStokvelIdCyclesCycleId({
    @Path('stokvelId') required String stokvelId,
    @Path('cycleId') required String cycleId,
    @Body() required CreateContributionCycleRequest body,
  });

  /// Delete a contribution cycle.
  ///
  /// Deletes the contribution cycle with the given id, as long as it belongs to the stokvel in the URL.  ///
  /// Returns `204` with no body.  ///
  ///  ///
  /// **Does not:** delete the contributions already recorded against the cycle. They are left behind.  ///
  /// Once the cycle is gone, no new contribution can be recorded against it (that gives `404`).  ///
  ///  ///
  /// **Errors:** `400` if `stokvelId` or `cycleId` is not a valid GUID; `404` if the cycle does not.  ///
  /// exist or does not belong to this stokvel (so deleting the same cycle twice gives `204` and then.  ///
  /// `404`).
  @DELETE('/api/v1/stokvels/{stokvelId}/cycles/{cycleId}')
  Future<void> deleteApiV1StokvelsStokvelIdCyclesCycleId({
    @Path('stokvelId') required String stokvelId,
    @Path('cycleId') required String cycleId,
  });
}
