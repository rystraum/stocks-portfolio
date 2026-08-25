import React, { useEffect, useState } from 'react';

const csrfToken = () => {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
};

const formatCurrency = (amount, places = 2) => {
  if (amount === null || amount === undefined || amount === '') return '-';
  const n = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (Number.isNaN(n)) return '-';
  return n.toLocaleString(undefined, {
    minimumFractionDigits: places,
    maximumFractionDigits: places,
  });
};

const titleize = (str) => {
  if (!str) return '';
  return str.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase());
};

const CryptoImportReview = ({ importId }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [resolvingItemId, setResolvingItemId] = useState(null);

  const fetchData = () => {
    fetch(`/crypto_activity_imports/${importId}.json`)
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load import data');
        return res.json();
      })
      .then((json) => {
        setData(json);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchData();
  }, [importId]);

  const resolveItem = (itemId, resolution) => {
    setResolvingItemId(itemId);
    const formData = new URLSearchParams();
    formData.append('item_id', itemId);
    formData.append('resolution', resolution);

    fetch(`/crypto_activity_imports/${importId}/resolve`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': csrfToken(),
        Accept: 'application/json',
      },
      body: formData.toString(),
    })
      .then((res) => {
        if (!res.ok) throw new Error('Failed to resolve duplicate');
        return res.json();
      })
      .then(() => {
        setResolvingItemId(null);
        fetchData();
      })
      .catch((err) => {
        setResolvingItemId(null);
        alert(err.message);
      });
  };

  const finalizeImport = () => {
    if (!window.confirm('Are you sure you want to finalize this import?')) return;

    fetch(`/crypto_activity_imports/${importId}/finalize`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken(),
        Accept: 'application/json',
      },
    })
      .then((res) => {
        if (!res.ok) throw new Error('Failed to finalize import');
        return res.json();
      })
      .then((json) => {
        if (json.redirect_url) {
          window.location.href = json.redirect_url;
        } else {
          fetchData();
        }
      })
      .catch((err) => alert(err.message));
  };

  if (loading) {
    return (
      <div className="p-4 text-center">
        <div className="spinner-border" role="status">
          <span className="sr-only">Loading...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 text-center text-red-500">
        Error: {error}
      </div>
    );
  }

  if (!data) return null;

  const { import: importData, items } = data;
  const unresolvedCount = items.filter(
    (i) => i.duplicate && i.resolution === 'pending'
  ).length;
  const isResolving = importData.status === 'resolving';

  const statusBadgeClass =
    importData.status === 'completed'
      ? 'badge-soft-success'
      : importData.status === 'resolving'
      ? 'badge-soft-warning'
      : 'badge-soft-danger';

  return (
    <div>
      <div className="flex gap-4 mb-6">
        <div className="card w-1/4">
          <div className="card-body text-center">
            <h5 className="text-muted">Status</h5>
            <span className={`badge ${statusBadgeClass}`}>
              {titleize(importData.status)}
            </span>
          </div>
        </div>
        <div className="card w-1/4">
          <div className="card-body text-center">
            <h5 className="text-muted">Total Items</h5>
            <h3>{items.length}</h3>
          </div>
        </div>
        <div className="card w-1/4">
          <div className="card-body text-center">
            <h5 className="text-muted">Duplicates</h5>
            <h3>{items.filter((i) => i.duplicate).length}</h3>
          </div>
        </div>
        <div className="card w-1/4">
          <div className="card-body text-center">
            <h5 className="text-muted">Created Activities</h5>
            <h3>{importData.created_activities_count || 0}</h3>
          </div>
        </div>
      </div>

      {isResolving && unresolvedCount > 0 && (
        <div className="alert alert-warning mb-4">
          <strong>Duplicates detected!</strong> Please review and resolve each
          potential duplicate below before finalizing the import.
        </div>
      )}

      {isResolving && unresolvedCount === 0 && (
        <div className="alert alert-success mb-4">
          All duplicates resolved. You can now finalize the import.
        </div>
      )}

      {isResolving && unresolvedCount === 0 && (
        <div className="flex justify-center mb-6">
          <button onClick={finalizeImport} className="btn btn-success">
            Finalize Import
          </button>
        </div>
      )}

      {items.map((item, idx) => {
        const hasDuplicate = !!item.duplicate;
        const isResolved = item.resolution !== 'pending';
        const isPending = resolvingItemId === item.id;
        const borderClass = hasDuplicate
          ? isResolved
            ? 'border-success'
            : 'border-warning'
          : '';

        return (
          <div key={item.id} className={`card mb-4 ${borderClass}`}>
            <div className="card-header flex items-center justify-between">
              <h4 className="card-header-title">
                #{idx + 1} {item.crypto_currency?.compound_ticker}{' '}
                {titleize(item.activity_type)}
                {hasDuplicate && !isResolved && (
                  <span className="badge badge-soft-warning ml-2">
                    Potential Duplicate
                  </span>
                )}
                {isResolved && item.resolution === 'accept' && (
                  <span className="badge badge-soft-success ml-2">
                    Accept Import
                  </span>
                )}
                {isResolved && item.resolution === 'ignore' && (
                  <span className="badge badge-soft-danger ml-2">
                    Keep Existing
                  </span>
                )}
              </h4>
              <small className="text-muted">Order #{item.order_id}</small>
            </div>

            <div className="card-body">
              <div className="block lg:flex gap-4">
                {/* Imported Transaction */}
                <div className="w-full lg:w-1/2">
                  <h5 className="font-bold mb-3 text-blue-600">
                    Imported Transaction
                  </h5>
                  <table className="table table-sm table-bordered w-full">
                    <tbody>
                      <tr>
                        <td className="font-bold w-1/3">Date</td>
                        <td>{item.activity_date}</td>
                      </tr>
                      <tr>
                        <td className="font-bold">Type</td>
                        <td>{titleize(item.activity_type)}</td>
                      </tr>
                      <tr>
                        <td className="font-bold">Crypto</td>
                        <td>
                          {formatCurrency(item.crypto_amount, 8)}{' '}
                          {item.crypto_currency?.pretty_ticker ||
                            item.crypto_currency?.ticker}
                        </td>
                      </tr>
                      <tr>
                        <td className="font-bold">Fiat</td>
                        <td>
                          {formatCurrency(item.fiat_amount)}{' '}
                          {item.crypto_currency?.quote_token}
                        </td>
                      </tr>
                      <tr>
                        <td className="font-bold">Fee (Crypto)</td>
                        <td>
                          {parseFloat(item.fee_crypto) > 0
                            ? formatCurrency(item.fee_crypto, 8)
                            : '-'}
                        </td>
                      </tr>
                      <tr>
                        <td className="font-bold">Fee (Fiat)</td>
                        <td>
                          {parseFloat(item.fee_fiat) > 0
                            ? formatCurrency(item.fee_fiat)
                            : '-'}
                        </td>
                      </tr>
                      <tr>
                        <td className="font-bold">Notes</td>
                        <td>{item.notes}</td>
                      </tr>
                    </tbody>
                  </table>

                  {item.raw_rows && item.raw_rows.length > 0 && (
                    <details className="mt-2">
                      <summary className="cursor-pointer text-sm text-muted">
                        View {item.raw_rows.length} raw CSV row(s)
                      </summary>
                      <table className="table table-sm table-striped mt-2">
                        <thead>
                          <tr>
                            <th>Price</th>
                            <th>Executed</th>
                            <th>Total</th>
                            <th>Fee</th>
                          </tr>
                        </thead>
                        <tbody>
                          {item.raw_rows.map((row, ridx) => (
                            <tr key={ridx}>
                              <td>{formatCurrency(row.executed_price)}</td>
                              <td>{row.executed}</td>
                              <td>{formatCurrency(row.total)}</td>
                              <td>{row.fee}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </details>
                  )}
                </div>

                {/* Existing Transaction */}
                <div className="w-full lg:w-1/2">
                  {hasDuplicate ? (
                    <>
                      <h5 className="font-bold mb-3 text-orange-600">
                        Existing Transaction
                      </h5>
                      <table className="table table-sm table-bordered w-full">
                        <tbody>
                          <tr>
                            <td className="font-bold w-1/3">Date</td>
                            <td>{item.duplicate.activity_date}</td>
                          </tr>
                          <tr>
                            <td className="font-bold">Type</td>
                            <td>
                              {titleize(item.duplicate.activity_type)}
                            </td>
                          </tr>
                          <tr>
                            <td className="font-bold">Crypto</td>
                            <td>
                              {formatCurrency(
                                item.duplicate.crypto_amount,
                                8
                              )}{' '}
                              {item.duplicate.crypto_currency
                                ?.pretty_ticker ||
                                item.duplicate.crypto_currency?.ticker}
                            </td>
                          </tr>
                          <tr>
                            <td className="font-bold">Fiat</td>
                            <td>
                              {formatCurrency(item.duplicate.fiat_amount)}{' '}
                              {item.duplicate.crypto_currency?.quote_token}
                            </td>
                          </tr>
                          <tr>
                            <td className="font-bold">Fee (Crypto)</td>
                            <td>
                              {parseFloat(item.duplicate.fee_crypto) > 0
                                ? formatCurrency(
                                    item.duplicate.fee_crypto,
                                    8
                                  )
                                : '-'}
                            </td>
                          </tr>
                          <tr>
                            <td className="font-bold">Fee (Fiat)</td>
                            <td>
                              {parseFloat(item.duplicate.fee_fiat) > 0
                                ? formatCurrency(item.duplicate.fee_fiat)
                                : '-'}
                            </td>
                          </tr>
                          <tr>
                            <td className="font-bold">Notes</td>
                            <td>{item.duplicate.notes || '-'}</td>
                          </tr>
                        </tbody>
                      </table>
                    </>
                  ) : (
                    <>
                      <h5 className="font-bold mb-3 text-gray-500">
                        Existing Transaction
                      </h5>
                      <div className="p-4 bg-gray-100 rounded text-center text-muted">
                        No matching existing transaction found.
                      </div>
                    </>
                  )}
                </div>
              </div>

              {hasDuplicate && !isResolved && isResolving && (
                <div className="mt-4 flex justify-center gap-4">
                  <button
                    onClick={() => resolveItem(item.id, 'accept')}
                    disabled={isPending}
                    className={`btn btn-success ${
                      isPending ? 'opacity-50' : ''
                    }`}
                  >
                    {isPending
                      ? 'Processing...'
                      : 'Accept Import (Delete Existing)'}
                  </button>
                  <button
                    onClick={() => resolveItem(item.id, 'ignore')}
                    disabled={isPending}
                    className={`btn btn-danger ${
                      isPending ? 'opacity-50' : ''
                    }`}
                  >
                    {isPending
                      ? 'Processing...'
                      : 'Keep Existing (Ignore Import)'}
                  </button>
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default CryptoImportReview;
