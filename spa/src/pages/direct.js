import React, { Component, PureComponent } from "react";
import Grid from "../components/grid/Grid";
import renderItem from "../utils/grid/render-item";
import api from "../utils/api";
import "./transform.css";

class DirectItemRenderer extends PureComponent {
  render() {
    return renderItem({
      columns: [
        "id",
        "direct_batch_id",
        "transform_batch_id",
        "class_name",
        "criteria_type",
        "criteria",
        "count"
      ],
      formatters: [
        (value, index) => index + 1,
        null,
        null,
        null,
        null,
        null,
        value => (value.toLocaleString ? value.toLocaleString() : value)
      ],
      classNames: [null, null, null, "long", null, "long", null],
      ...this.props
    });
  }
}

// direct_batch_id transform_batch_id class_name                              criteria_type criteria                                                                                                                                            count
// --------------- ------------------ --------------------------------------- ------------- --------------------------------------------------------------------------------------------------------------------------------------------------- ------
// 1               76212              External::XPDM::ProductMembershipLoader partial       SELECT "PDM_ITEM_RLTN".* FROM "PDM_ITEM_RLTN" WHERE "PDM_ITEM_RLTN"."RLTN_TYPE" = 'WebProduct_to_SKU' AND (mod(pdm_item_rltn.pdm_object_id, 5) = 1) 498647

export default class Inbound extends Component {
  render() {
    return (
      <div>
        <h2>Direct Batches</h2>
        <Grid
          width={1600}
          height={400}
          rowHeight={35}
          columnWidths={[50, 75, 150, 275, 100, 825, 125]}
          columnNames={[
            "#",
            "id",
            "transform batch id",
            "class name",
            "criteria type",
            "criteria",
            "count"
          ]}
          itemName="direct batch"
          pluralItemName="direct batches"
          itemRenderer={DirectItemRenderer}
          url={api("direct_batches")}
        />
      </div>
    );
  }
}
