import React, { Component, PureComponent } from "react";
import Grid from "../components/grid/Grid";
import renderItem from "../utils/grid/render-item";
import api from "../utils/api";
import "./transform.css";

class InboundItemRenderer extends PureComponent {
  render() {
    return renderItem({
      columns: [
        "id",
        "inbound_batch_id",
        "source",
        "data_type",
        "status",
        "status_reason",
        "file_name",
        "start_datetime",
        "stop_datetime",
        "transform_batch_id"
      ],
      formatters: [
        (value, index) => index + 1,
        null,
        null,
        null,
        null,
        null,
        null,
        value => value && new Date(value).toLocaleString(),
        value => value && new Date(value).toLocaleString(),
        null
      ],
      classNames: [
        null,
        null,
        null,
        null,
        null,
        "statusReason",
        "fileName",
        null,
        null,
        null,
        null
      ],
      ...this.props
    });
  }
}

// inbound_batch_id source data_type   status   status_reason                                                                                     file_name                  start_datetime      stop_datetime       transform_batch_id
// ---------------- ------ ----------- -------- ------------------------------------------------------------------------------------------------- -------------------------- ------------------- ------------------- ------------------
// 79340            JDA    sku_pricing complete Completed successfully (0 records processed, taking 1.3978579999999998 sec). (Oct 14 10:05 (UTC)) AS/400(BEYOND): PIPPRCMSSW 2018-10-14 10:05:26 2018-10-14 10:05:28 76241

export default class Inbound extends Component {
  render() {
    return (
      <div>
        <h2>Inbound Batches</h2>
        <Grid
          width={1600}
          height={400}
          rowHeight={35}
          columnWidths={[50, 75, 100, 100, 75, 375, 300, 200, 200, 100]}
          columnNames={[
            "#",
            "id",
            "source",
            "data type",
            "status",
            "reason",
            "file_name",
            "start",
            "stop",
            "transform batch id"
          ]}
          itemName="inbound"
          itemRenderer={InboundItemRenderer}
          url={api("inbound_batches")}
          onSelectItem={this.onSelectItem}
        />
      </div>
    );
  }
}
