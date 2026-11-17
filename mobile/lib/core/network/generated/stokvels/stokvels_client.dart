// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/add_member_request.dart';
import '../models/contribution_request.dart';
import '../models/contribution_response.dart';
import '../models/create_stokvel_request.dart';
import '../models/paged_response_of_member_list_item.dart';
import '../models/payout_response.dart';
import '../models/payout_rotation_response.dart';
import '../models/stokvel_response.dart';
import '../models/update_payout_request.dart';

part 'stokvels_client.g.dart';

@RestApi()
abstract class StokvelsClient {
  factory StokvelsClient(Dio dio, {String? baseUrl}) = _StokvelsClient;

  /// Record a member's contribution for a cycle (idempotent).
  ///
  /// Records that a member has paid into one contribution cycle of this stokvel.
  ///
  /// **Idempotency-Key header (required):** send a unique value (for example a GUID) with every.
  /// new contribution. Scalar lists the header as optional because of how it is declared, but a.
  /// request without it is rejected with `422`.
  /// - Same key, same body: nothing new is recorded. You get back the original `201` response, identical to the first.
  /// - Same key, different body: rejected with `409`. Use a new key for a new contribution.
  /// - Only successful requests are remembered, so retrying after a failure runs the request again.
  /// - The key is compared with the request body only, not the stokvel id in the URL.
  /// - Keys are kept in memory: they are forgotten when the application restarts and never expire.
  ///
  /// **Checks, in this order:** the body is valid, the header is present, the key has not been used.
  /// before (a replay is answered here), the stokvel exists, the user exists, the user is a member.
  /// of this stokvel, the cycle exists and belongs to this stokvel, this member has not already paid.
  /// this cycle.
  ///
  /// **Does not:** check that `amount` matches the stokvel's contribution amount or the cycle's.
  /// target. Any amount above zero is accepted.
  ///
  /// **Errors:** `400` if `id` is not a valid GUID, `userId` or `contributionCycleId` is missing or.
  /// the empty GUID, `amount` is zero or less, or the body is not valid JSON;.
  /// `404` if the stokvel, the user, or the cycle does not exist, if the user is not a member of.
  /// this stokvel, or if the cycle belongs to a different stokvel; `409` if this member has already.
  /// paid this cycle, or the Idempotency-Key was already used with a different body;.
  /// `422` if the Idempotency-Key header is missing or blank.
  ///
  /// **Location header:** points to the stokvel (`GET /api/stokvels/{id}`), because contributions.
  /// have no endpoint of their own to fetch.
  ///
  /// **Example request** (with header `Idempotency-Key: 6b0f5c1e-9f0a-4d2b-8a55-3c7d1e2f4a60`):.
  ///
  ///     {.
  ///       "userId": "3f2b8c1e-5d4a-4c7b-9a10-1e2f3a4b5c6d",.
  ///       "amount": 500,.
  ///       "contributionCycleId": "b7e4a2d1-6c3f-4e58-9b20-5d1a0c9e8f77".
  ///     }.
  ///
  /// **Example response (201):**.
  ///
  ///     {.
  ///       "id": "e2a9c4b6-1d8f-4a73-b5c0-9f6e3d2a1b48",.
  ///       "stokvelId": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.
  ///       "userId": "3f2b8c1e-5d4a-4c7b-9a10-1e2f3a4b5c6d",.
  ///       "amount": 500,.
  ///       "contributionCycleId": "b7e4a2d1-6c3f-4e58-9b20-5d1a0c9e8f77",.
  ///       "createdAt": "2026-09-28T09:15:00Z".
  ///     }.
  @POST('/api/v1/stokvels/{id}/contributions')
  Future<ContributionResponse> postApiV1StokvelsIdContributions({
    @Path('id') required String id,
    @Body() required ContributionRequest body,
    @Header('Idempotency-Key') String? idempotencyKey,
  });

  /// List all stokvels.
  ///
  /// Returns every stokvel, in the order they were created. Each entry shows a `memberCount`.
  /// instead of the member list itself.
  ///
  /// **Guarantees:** always succeeds; returns an empty array if there are no stokvels.
  ///
  /// **Does not:** support paging, filtering or sorting, and does not list who the members are.
  ///
  /// **Example response (200):**.
  ///
  ///     [.
  ///       {.
  ///         "id": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.
  ///         "name": "Soweto Savings Club",.
  ///         "contributionAmount": 500,.
  ///         "memberCount": 2.
  ///       }.
  ///     ].
  @GET('/api/v1/stokvels')
  Future<List<StokvelResponse>> getApiV1Stokvels();

  /// Create a stokvel.
  ///
  /// Creates a new stokvel with no members. The server generates the `id`.
  ///
  /// **Rules:** `name` is required and at most 100 characters. `contributionAmount` must be greater.
  /// than zero.
  ///
  /// **Guarantees:** on `201`, the stokvel exists with `memberCount` 0, and a `Location` header.
  /// points to it.
  ///
  /// **Does not:** stop two stokvels sharing the same name.
  ///
  /// **Errors:** `400` if any rule above is broken, or the body is missing or is not valid JSON.
  ///
  /// **Example request:**.
  ///
  ///     { "name": "Soweto Savings Club", "contributionAmount": 500 }.
  ///
  /// **Example response (201):**.
  ///
  ///     {.
  ///       "id": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.
  ///       "name": "Soweto Savings Club",.
  ///       "contributionAmount": 500,.
  ///       "memberCount": 0.
  ///     }.
  @POST('/api/v1/stokvels')
  Future<StokvelResponse> postApiV1Stokvels({
    @Body() required CreateStokvelRequest body,
  });

  /// Get one stokvel by id.
  ///
  /// Returns the stokvel with the given id.
  ///
  /// **Guarantees:** a `200` always contains the full stokvel. An unknown id always gives `404`.
  ///
  /// **Errors:** `400` if `id` is not a valid GUID; `404` if no stokvel has that id.
  ///
  /// **Example response (200):**.
  ///
  ///     {.
  ///       "id": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.
  ///       "name": "Soweto Savings Club",.
  ///       "contributionAmount": 500,.
  ///       "memberCount": 2.
  ///     }.
  @GET('/api/v1/stokvels/{id}')
  Future<StokvelResponse> getApiV1StokvelsId({@Path('id') required String id});

  /// Replace a stokvel's name and contribution amount.
  ///
  /// Replaces **both** fields of an existing stokvel. This is a full update, not a partial one:.
  /// send `name` and `contributionAmount` every time. The `id` and the member list are not changed.
  ///
  /// **Rules:** the same as creating a stokvel.
  ///
  /// **Errors:** `400` if `id` is not a valid GUID or a rule is broken (checked before the lookup, so an.
  /// invalid body for an unknown id gives `400`, not `404`); `404` if no stokvel has that id.
  ///
  /// **Example request:**.
  ///
  ///     { "name": "Soweto Savings Club", "contributionAmount": 750 }.
  ///
  /// **Example response (200):**.
  ///
  ///     {.
  ///       "id": "9c1d7e40-2b6a-4f3e-8d55-7a0b1c2d3e4f",.
  ///       "name": "Soweto Savings Club",.
  ///       "contributionAmount": 750,.
  ///       "memberCount": 2.
  ///     }.
  @PUT('/api/v1/stokvels/{id}')
  Future<StokvelResponse> putApiV1StokvelsId({
    @Path('id') required String id,
    @Body() required CreateStokvelRequest body,
  });

  /// Delete a stokvel.
  ///
  /// Deletes the stokvel with the given id. Returns `204` with no body.
  ///
  /// **Does not:** delete the stokvel's contribution cycles or recorded contributions. They are left.
  /// behind but can no longer be reached, because every cycle route needs an existing stokvel.
  ///
  /// **Errors:** `400` if `id` is not a valid GUID; `404` if no stokvel has that id (so deleting the.
  /// same stokvel twice gives `204` and then `404`).
  @DELETE('/api/v1/stokvels/{id}')
  Future<void> deleteApiV1StokvelsId({@Path('id') required String id});

  /// List members of a stokvel (paged).
  ///
  /// Returns the members of the given stokvel, paged and sorted in the database.
  /// Default page size is 20, maximum is 100. Negative page_size returns 400.
  /// The page_token is opaque. An empty nextPageToken means there are no more results.
  @GET('/api/v1/stokvels/{id}/members')
  Future<PagedResponseOfMemberListItem> getApiV1StokvelsIdMembers({
    @Path('id') required String id,
    @Query('page_size') dynamic pageSize,
    @Query('page_token') String? pageToken,
    @Query('sort') String? sort,
  });

  /// Add a user to a stokvel as a member.
  ///
  /// Makes an existing user a member of an existing stokvel. Returns `204` with no body; call.
  /// `GET /api/stokvels/{id}` and check `memberCount` to see the result.
  ///
  /// **Checks, in this order:** the body is valid, the stokvel exists, the user exists, the user is.
  /// not already a member.
  ///
  /// **Errors:** `400` if `id` is not a valid GUID, `userId` is missing or the empty GUID, or the body.
  /// is not valid JSON; `404` if the stokvel or the user does not exist; `409` if the user is already.
  /// a member of this stokvel.
  ///
  /// **Example request:**.
  ///
  ///     { "userId": "3f2b8c1e-5d4a-4c7b-9a10-1e2f3a4b5c6d" }.
  @POST('/api/v1/stokvels/{id}/members')
  Future<void> postApiV1StokvelsIdMembers({
    @Path('id') required String id,
    @Body() required AddMemberRequest body,
  });

  /// Get the server-owned payout rotation.
  ///
  /// Returns stokvel members in deterministic payout order,.
  /// with recorded payout amounts and the next eligible recipient.
  /// Only members of the stokvel can access this endpoint.
  /// Scheduled dates are null until scheduling rules are defined.
  /// A paid-out cycle does not advertise another actionable payout.
  @GET('/api/v1/stokvels/{id}/cycles/{cycleId}/payout-rotation')
  Future<PayoutRotationResponse> getApiV1StokvelsIdCyclesCycleIdPayoutRotation({
    @Path('id') required String id,
    @Path('cycleId') required String cycleId,
  });

  /// Get the payout for a contribution cycle.
  ///
  /// Returns the payout recorded for the given contribution cycle, including the.
  /// PostgreSQL xmin concurrency token as `version`.
  ///
  /// The returned `version` must be supplied when updating the payout.
  @GET('/api/v1/stokvels/{id}/cycles/{cycleId}/payout')
  Future<PayoutResponse> getApiV1StokvelsIdCyclesCycleIdPayout({
    @Path('id') required String id,
    @Path('cycleId') required String cycleId,
  });

  /// Update a payout amount using optimistic concurrency.
  ///
  /// Updates the payout amount.
  ///
  /// The `version` returned by GET must be supplied with the request.
  /// If another request has already changed the payout, the stale version.
  /// is rejected with 409 Conflict.
  @PUT('/api/v1/stokvels/{id}/cycles/{cycleId}/payout')
  Future<PayoutResponse> putApiV1StokvelsIdCyclesCycleIdPayout({
    @Path('id') required String id,
    @Path('cycleId') required String cycleId,
    @Body() required UpdatePayoutRequest body,
  });

  /// Process the next payout for a contribution cycle.
  ///
  /// Determines the next eligible recipient — the member who joined this stokvel earliest.
  /// and has not yet received a payout from it — records a Payout for them, and marks the.
  /// cycle as paid out. Both writes happen inside one database transaction: either both.
  /// succeed, or neither is kept.
  ///
  /// **Errors:** `404` if the stokvel or cycle does not exist, or the cycle does not belong.
  /// to this stokvel; `409` if the cycle has already been paid out, or every member has.
  /// already received a payout from this stokvel.
  @POST('/api/v1/stokvels/{id}/cycles/{cycleId}/payout')
  Future<PayoutResponse> postApiV1StokvelsIdCyclesCycleIdPayout({
    @Path('id') required String id,
    @Path('cycleId') required String cycleId,
  });
}
