import { VariableSizeGrid } from "react-window";
import React, { forwardRef, Component } from "react";
import Header from "../../components/grid/Header";
import Footer from "./Footer";

export default class Grid extends Component {
  constructor(props) {
    super(props);
    this.state = {
      data: null,
      unfilteredData: null,
      selected: null
    };
    this.gridRef = React.createRef();
  }

  extractData = response => {
    const method = this.props.setData || (data => data);
    return method(response);
  };

  componentDidMount() {
    fetch(this.props.url)
      .then(response => response.json())
      .then(data => this.extractData(data))
      .then(data => this.setState({ data }));
  }

  onClick({ target }) {
    const { onSelectItem, onClickItem } = this.props;
    const dataId = target.getAttribute("data-id");
    const item = this.state.data && this.state.data[dataId];

    if (onClickItem) {
      onClickItem(item);
    }

    if (onSelectItem) {
      if (this.state.selected) {
        // clear already selected item
        this.setState(prevState => {
          return {
            data: prevState.unfilteredData,
            unfilteredData: null,
            selected: null
          };
        });
      }

      if (item) {
        if (!this.state.selected) {
          // set selected state
          this.gridRef.current.scrollToItem({
            align: "start",
            rowIndex: 0
          });
          this.setState(prevState => {
            return {
              data: [item],
              unfilteredData: prevState.unfilteredData || prevState.data,
              selected: item
            };
          });
        } else {
        }
      }

      onSelectItem(item);
    }
  }

  count() {
    let count = "none";
    if (this.state.data && this.state.data.length) {
      count = this.state.data.length;
    }
    return count;
  }

  render() {
    const {
      width,
      height,
      rowHeight,
      columnNames,
      columnWidths,
      itemName,
      pluralItemName,
      itemRenderer
    } = this.props;

    const outerElementType = forwardRef((props, ref) => {
      return <div ref={ref} onClick={this.onClick.bind(this)} {...props} />;
    });

    return (
      <div>
        {this.state.data && this.state.data.length > 0 && (
          <div>
            <Header
              columnWidths={columnWidths}
              width={width}
              rowHeight={rowHeight}
              columnNames={columnNames}
            />
            <VariableSizeGrid
              itemData={this.state.data}
              className="List"
              columnCount={columnWidths.length}
              columnWidth={index => columnWidths[index]}
              outerElementType={outerElementType}
              height={this.state.selected ? rowHeight : height}
              rowCount={this.state.data.length}
              rowHeight={() => rowHeight}
              width={width}
              ref={this.gridRef}
            >
              {itemRenderer}
            </VariableSizeGrid>
          </div>
        )}
        <Footer
          count={this.count()}
          itemName={itemName}
          pluralItemName={pluralItemName}
        />
      </div>
    );
  }
}
